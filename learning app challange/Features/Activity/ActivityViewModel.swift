import Foundation
import Observation

/// Screens reachable from the Activity header.
enum ActivityRoute: Hashable {
    case calendar, editGoal
}

/// What to show once the goal period is over.
struct GoalEndedContent {
    let icon: String
    let title: String
    let subtitle: String
}

/// State and actions for the main Activity screen.
@Observable
final class ActivityViewModel {
    var path: [ActivityRoute] = []

    private let store: LearningStore
    private let calendar = Calendar.current

    init(store: LearningStore) {
        self.store = store
    }

    // MARK: - Header

    var dateText: String {
        store.today.formatted(.dateTime.weekday(.wide).day().month(.wide))
    }

    var goalText: String? {
        guard let goal = store.goal else { return nil }
        return "Learning \(goal.subject) this \(goal.period.title.lowercased())"
    }

    // MARK: - Week strip

    /// The seven days (Sunday–Saturday) of the week containing today.
    var weekDays: [DayItem] {
        guard let week = calendar.dateInterval(of: .weekOfYear, for: store.today) else { return [] }
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: week.start).map { dayItem(for: $0) }
        }
    }

    func weekdayLetter(for date: Date) -> String {
        date.formatted(.dateTime.weekday(.narrow))
    }

    // MARK: - Stats

    var learnedCount: Int { store.learnedCount }
    var freezedCount: Int { store.freezedCount }

    // MARK: - Today

    var isGoalInProgress: Bool { store.outcome == .inProgress }

    var canLogLearned: Bool { store.todayStatus != .learned }
    var logButtonTitle: String { canLogLearned ? "Log as Learned" : "Logged as Learned" }

    var canFreeze: Bool { store.canFreezeToday }
    var freezeButtonTitle: String { store.todayStatus == .freezed ? "Freezed for a day" : "Freeze for a day" }
    var freezesUsedText: String { "\(store.freezedCount) out of \(store.allowedFreezes) Freezes used" }

    var goalEndedContent: GoalEndedContent? {
        switch store.outcome {
        case .inProgress:
            nil
        case .completed:
            GoalEndedContent(icon: "hands.clap.fill", title: "Well done!", subtitle: "Ready for your next goal?")
        case .notMet:
            GoalEndedContent(icon: "xmark.seal", title: "You didn't reach your goal this time.", subtitle: "Want to set another goal?")
        }
    }

    // MARK: - Actions

    func logLearned() { store.logLearnedToday() }
    func freeze() { store.freezeToday() }
    func showCalendar() { path.append(.calendar) }
    func showGoalEditor() { path.append(.editGoal) }

    private func dayItem(for date: Date) -> DayItem {
        DayItem(date: date, status: store.status(on: date), isToday: date == store.today)
    }
}
