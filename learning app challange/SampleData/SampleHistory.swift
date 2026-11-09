#if DEBUG
import Foundation

/// Dummy activity for the three months before the current one, so the calendar
/// and yearly totals have something to show while developing.
/// Compiled into Debug builds only; Release builds start with an empty history.
enum SampleHistory {
    private static let seededKey = "learningJourney.sampleHistorySeeded"
    private static let monthsBack = 3

    /// Seeds the store once per install. Never touches days the learner logged.
    static func seedIfNeeded(_ store: LearningStore, defaults: UserDefaults = .standard) {
        guard !defaults.bool(forKey: seededKey) else { return }
        store.importHistory(entries())
        defaults.set(true, forKey: seededKey)
    }

    /// A repeatable pattern: mostly learned days, a freeze every 6th day, a missed day every 9th.
    static func entries(calendar: Calendar = .current, now: Date = .now) -> [Date: DayStatus] {
        guard let thisMonth = calendar.dateInterval(of: .month, for: now)?.start,
              let firstDay = calendar.date(byAdding: .month, value: -monthsBack, to: thisMonth) else { return [:] }

        var entries: [Date: DayStatus] = [:]
        var day = firstDay
        var index = 0
        while day < thisMonth {
            index += 1
            let isMissed = index % 9 == 0
            if !isMissed {
                entries[day] = index % 6 == 0 ? .freezed : .learned
            }
            guard let next = calendar.date(byAdding: .day, value: 1, to: day) else { break }
            day = next
        }
        return entries
    }
}
#endif
