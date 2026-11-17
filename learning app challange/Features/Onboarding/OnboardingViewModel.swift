import Foundation
import Observation

/// State and actions for the first-launch screen.
@Observable
final class OnboardingViewModel {
    var subject = ""
    var period: GoalPeriod = .week

    private let store: LearningStore

    init(store: LearningStore) {
        self.store = store
    }

    func startLearning() {
        store.setGoal(subject: subject, period: period)
    }
}
