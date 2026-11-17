import Foundation
import Observation

/// State and actions for editing the current goal or setting the next one.
@Observable
final class LearningGoalViewModel {
    var subject: String
    var period: GoalPeriod
    var showsUpdateAlert = false
    /// Becomes `true` once the goal is saved, telling the View to close.
    private(set) var isFinished = false

    private let store: LearningStore

    init(store: LearningStore) {
        self.store = store
        subject = store.goal?.subject ?? ""
        period = store.goal?.period ?? .week
    }

    func saveTapped() {
        // A finished goal has no streak left to lose, so there is nothing to warn about.
        if store.outcome == .inProgress {
            showsUpdateAlert = true
        } else {
            confirmUpdate()
        }
    }

    func confirmUpdate() {
        store.setGoal(subject: subject, period: period)
        isFinished = true
    }
}
