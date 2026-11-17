import Foundation
import Observation

/// Display data for one month of the calendar.
struct CalendarMonth: Identifiable {
    let firstDay: Date
    let title: String
    /// Empty cells before day 1 so it lands under the right weekday.
    let leadingBlankDays: Int
    let days: [DayItem]

    var id: Date { firstDay }
}

/// State for the "Activities" screen: yearly totals and every month since the learner started.
@Observable
final class CalendarViewModel {
    private let store: LearningStore
    private let calendar = Calendar.current

    init(store: LearningStore) {
        self.store = store
    }

    var learnedThisYear: Int { store.totals(inYearOf: store.today).learned }
    var freezedThisYear: Int { store.totals(inYearOf: store.today).freezed }

    /// Weekday headers starting at the locale's first weekday.
    var weekdaySymbols: [String] {
        let symbols = calendar.shortWeekdaySymbols.map { $0.uppercased() }
        let first = calendar.firstWeekday - 1
        return Array(symbols[first...] + symbols[..<first])
    }

    /// Every month from the earliest recorded day through the current month.
    var months: [CalendarMonth] {
        guard var monthStart = calendar.dateInterval(of: .month, for: store.earliestRecordedDay)?.start,
              let lastMonth = calendar.dateInterval(of: .month, for: store.today)?.start else { return [] }

        var months: [CalendarMonth] = []
        while monthStart <= lastMonth {
            months.append(month(startingAt: monthStart))
            guard let next = calendar.date(byAdding: .month, value: 1, to: monthStart) else { break }
            monthStart = next
        }
        return months
    }

    /// The month the screen should open scrolled to.
    var currentMonthID: Date? {
        calendar.dateInterval(of: .month, for: store.today)?.start
    }

    private func month(startingAt firstDay: Date) -> CalendarMonth {
        let dayRange = calendar.range(of: .day, in: .month, for: firstDay) ?? 1..<1
        let days = dayRange.compactMap { calendar.date(byAdding: .day, value: $0 - 1, to: firstDay) }
        return CalendarMonth(
            firstDay: firstDay,
            title: firstDay.formatted(.dateTime.month(.wide).year()),
            leadingBlankDays: (calendar.component(.weekday, from: firstDay) - calendar.firstWeekday + 7) % 7,
            days: days.map { DayItem(date: $0, status: store.status(on: $0), isToday: $0 == store.today) }
        )
    }
}
