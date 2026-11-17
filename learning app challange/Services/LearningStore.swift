import Foundation
import Observation

/// Data layer and single source of truth: holds the goal and the daily log,
/// applies the goal rules, and persists everything to UserDefaults as JSON.
/// ViewModels read from and write to it; Views never talk to it directly.
@Observable
final class LearningStore {
    private struct Snapshot: Codable {
        var goal: LearningGoal?
        var log: [Date: DayStatus]
    }

    private static let storageKey = "learningJourney.snapshot"
    private let defaults: UserDefaults
    private let calendar = Calendar.current

    /// `nil` until the learner finishes onboarding; never cleared afterwards.
    private(set) var goal: LearningGoal? { didSet { save() } }

    /// Every day ever logged, keyed by the start of that day.
    /// Kept across goals so the calendar and yearly totals show the full history.
    private(set) var log: [Date: DayStatus] = [:] { didSet { save() } }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: Self.storageKey),
           let snapshot = try? JSONDecoder().decode(Snapshot.self, from: data) {
            goal = snapshot.goal
            log = snapshot.log
        }
    }

    // MARK: - Days

    var today: Date { calendar.startOfDay(for: .now) }

    var todayStatus: DayStatus? { log[today] }

    func status(on date: Date) -> DayStatus? {
        log[calendar.startOfDay(for: date)]
    }

    /// The first day anything was recorded, or today when the history is empty.
    var earliestRecordedDay: Date {
        (log.keys + [goal?.startDate].compactMap { $0 }).min() ?? today
    }

    // MARK: - Current goal

    var hasCompletedOnboarding: Bool { goal != nil }

    /// Days logged since the current goal started. Resets whenever a new goal is set.
    var learnedCount: Int { goalLog.values.count(where: { $0 == .learned }) }
    var freezedCount: Int { goalLog.values.count(where: { $0 == .freezed }) }

    var allowedFreezes: Int { goal?.period.allowedFreezes ?? 0 }

    /// Today can be switched to freezed — even after logging it as learned —
    /// as long as it isn't freezed already and a freeze is left.
    var canFreezeToday: Bool { todayStatus != .freezed && freezedCount < allowedFreezes }

    var outcome: GoalOutcome {
        guard let goal, let end = endDate(of: goal), today >= end else { return .inProgress }
        return goalLog.count >= goal.period.durationInDays ? .completed : .notMet
    }

    private var goalLog: [Date: DayStatus] {
        guard let goal, let end = endDate(of: goal) else { return [:] }
        let start = calendar.startOfDay(for: goal.startDate)
        return log.filter { (start..<end).contains($0.key) }
    }

    private func endDate(of goal: LearningGoal) -> Date? {
        calendar.date(byAdding: .day, value: goal.period.durationInDays, to: calendar.startOfDay(for: goal.startDate))
    }

    // MARK: - History

    /// Totals for a whole calendar year, across every goal in that year.
    func totals(inYearOf date: Date) -> (learned: Int, freezed: Int) {
        let yearLog = log.filter { calendar.isDate($0.key, equalTo: date, toGranularity: .year) }
        return (yearLog.values.count(where: { $0 == .learned }), yearLog.values.count(where: { $0 == .freezed }))
    }

    // MARK: - Actions

    /// Starts a fresh goal today. The streak starts over; past days stay in the history.
    func setGoal(subject: String, period: GoalPeriod) {
        // Replacing a goal mid-way starts over from an empty today, as the
        // "Update goal" alert promises, so the learner logs today again.
        if goal != nil, outcome == .inProgress {
            log[today] = nil
        }
        let trimmed = subject.trimmingCharacters(in: .whitespacesAndNewlines)
        goal = LearningGoal(subject: trimmed.isEmpty ? "Swift" : trimmed, period: period, startDate: today)
    }

    /// Logs today as learned. Replaces a freeze, which gives that freeze back.
    func logLearnedToday() {
        guard todayStatus != .learned else { return }
        log[today] = .learned
    }

    /// Freezes today. Replaces a "learned" log if the learner switches their mind.
    func freezeToday() {
        guard canFreezeToday else { return }
        log[today] = .freezed
    }

    /// Adds past days without overwriting anything the learner logged. Used for sample data.
    func importHistory(_ entries: [Date: DayStatus]) {
        let normalized = Dictionary(entries.map { (calendar.startOfDay(for: $0.key), $0.value) }) { first, _ in first }
        log.merge(normalized) { existing, _ in existing }
    }

    // MARK: - Persistence

    private func save() {
        guard let data = try? JSONEncoder().encode(Snapshot(goal: goal, log: log)) else { return }
        defaults.set(data, forKey: Self.storageKey)
    }
}
