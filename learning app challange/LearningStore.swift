import Foundation
import Observation

enum GoalPeriod: String, Codable, CaseIterable, Identifiable {
    case week, month, year

    var id: Self { self }

    var title: String {
        switch self {
        case .week: "Week"
        case .month: "Month"
        case .year: "Year"
        }
    }

    /// Number of days a goal of this period lasts.
    var durationInDays: Int {
        switch self {
        case .week: 7
        case .month: 30
        case .year: 365
        }
    }

    /// How many days the learner may freeze during one goal.
    var allowedFreezes: Int {
        switch self {
        case .week: 2
        case .month: 8
        case .year: 96
        }
    }
}

enum DayStatus: String, Codable {
    case learned, freezed
}

struct LearningGoal: Codable, Equatable {
    var subject: String
    var period: GoalPeriod
    var startDate: Date
}

enum GoalOutcome {
    case inProgress, completed, notMet
}

/// Single source of truth for the app. Persists itself to UserDefaults as JSON.
@Observable
final class LearningStore {
    private struct Snapshot: Codable {
        var goal: LearningGoal?
        var log: [Date: DayStatus]
    }

    private static let storageKey = "learningJourney.snapshot"
    private let defaults: UserDefaults
    private let calendar = Calendar.current

    private(set) var goal: LearningGoal? { didSet { save() } }
    /// Every day ever logged, keyed by the start of that day. Kept across goals so the calendar shows full history.
    private(set) var log: [Date: DayStatus] = [:] { didSet { save() } }

    /// Overridable "now" so previews can render a fixed day.
    var now: () -> Date = Date.init

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: Self.storageKey),
           let snapshot = try? JSONDecoder().decode(Snapshot.self, from: data) {
            goal = snapshot.goal
            log = snapshot.log
        }
    }

    // MARK: - Derived state

    var today: Date { calendar.startOfDay(for: now()) }

    var todayStatus: DayStatus? { log[today] }

    func status(on date: Date) -> DayStatus? {
        log[calendar.startOfDay(for: date)]
    }

    /// Logged days that belong to the current goal.
    private var goalLog: [Date: DayStatus] {
        guard let goal else { return [:] }
        let start = calendar.startOfDay(for: goal.startDate)
        return log.filter { $0.key >= start && $0.key < goalEndDate(goal) }
    }

    var learnedCount: Int { goalLog.values.filter { $0 == .learned }.count }
    var freezedCount: Int { goalLog.values.filter { $0 == .freezed }.count }
    var allowedFreezes: Int { goal?.period.allowedFreezes ?? 0 }
    var canFreeze: Bool { todayStatus == nil && freezedCount < allowedFreezes }

    var outcome: GoalOutcome {
        guard let goal, today >= goalEndDate(goal) else { return .inProgress }
        return goalLog.count >= goal.period.durationInDays ? .completed : .notMet
    }

    /// The seven days (Sunday–Saturday) of the week containing today.
    var currentWeek: [Date] {
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: today) else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: interval.start) }
    }

    /// First day of every month from the earliest logged/goal month through the current month.
    var monthsWithHistory: [Date] {
        let earliest = ([goal?.startDate].compactMap { $0 } + Array(log.keys)).min() ?? today
        guard var month = calendar.dateInterval(of: .month, for: earliest)?.start,
              let last = calendar.dateInterval(of: .month, for: today)?.start else { return [] }
        var months: [Date] = []
        while month <= last {
            months.append(month)
            month = calendar.date(byAdding: .month, value: 1, to: month)!
        }
        return months
    }

    private func goalEndDate(_ goal: LearningGoal) -> Date {
        calendar.date(byAdding: .day, value: goal.period.durationInDays, to: calendar.startOfDay(for: goal.startDate))!
    }

    // MARK: - Actions

    /// Starts a fresh goal today. The streak starts over; past days stay in the calendar.
    func setGoal(subject: String, period: GoalPeriod) {
        let trimmed = subject.trimmingCharacters(in: .whitespacesAndNewlines)
        goal = LearningGoal(subject: trimmed.isEmpty ? "Swift" : trimmed, period: period, startDate: today)
    }

    func logLearnedToday() {
        guard todayStatus != .learned else { return }
        log[today] = .learned
    }

    func freezeToday() {
        guard canFreeze else { return }
        log[today] = .freezed
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(Snapshot(goal: goal, log: log)) else { return }
        defaults.set(data, forKey: Self.storageKey)
    }
}
