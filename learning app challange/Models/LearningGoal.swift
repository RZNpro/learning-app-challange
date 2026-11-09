import Foundation

/// What the learner wants to learn, and for how long.
struct LearningGoal: Codable, Equatable {
    var subject: String
    var period: GoalPeriod
    var startDate: Date
}

/// The length of a learning goal.
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

/// How a single day was logged.
enum DayStatus: String, Codable {
    case learned, freezed
}

/// Where the current goal stands.
enum GoalOutcome {
    case inProgress, completed, notMet
}
