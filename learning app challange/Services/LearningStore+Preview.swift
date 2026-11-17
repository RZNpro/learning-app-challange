#if DEBUG
import Foundation

extension LearningStore {
    /// An in-memory store for SwiftUI previews, optionally with a goal and sample history.
    static func preview(goal period: GoalPeriod? = nil) -> LearningStore {
        let store = LearningStore(defaults: UserDefaults(suiteName: "preview-\(UUID())")!)
        if let period {
            store.setGoal(subject: "Swift", period: period)
            store.importHistory(SampleHistory.entries())
        }
        return store
    }
}
#endif
