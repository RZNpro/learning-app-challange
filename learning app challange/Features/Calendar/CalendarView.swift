import SwiftUI

/// "Activities": this year's totals, then every month since the learner started.
struct CalendarView: View {
    @Environment(LearningStore.self) private var store

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    YearSummary()
                        .padding(.horizontal, 4)
                        .padding(.bottom, 8)

                    ForEach(store.monthsWithHistory, id: \.self) { month in
                        MonthGrid(month: month)
                            .id(month)
                        Divider()
                    }
                }
                .padding(.horizontal, 12)
            }
            .onAppear {
                proxy.scrollTo(store.monthsWithHistory.last, anchor: .top)
            }
        }
        .navigationTitle("Activities")
        .inlineNavigationTitle()
    }
}

/// Learned / freezed totals for the current calendar year, across all goals.
private struct YearSummary: View {
    @Environment(LearningStore.self) private var store

    var body: some View {
        let totals = store.totals(inYearOf: store.today)
        VStack(alignment: .leading, spacing: 8) {
            Text("This year")
                .font(.title3.weight(.semibold))
                .padding(.horizontal, 4)
            HStack(spacing: 12) {
                StatCard.learned(totals.learned)
                StatCard.freezed(totals.freezed)
            }
        }
        .padding(.top, 16)
    }
}

/// One month laid out as a seven-column grid.
private struct MonthGrid: View {
    @Environment(LearningStore.self) private var store
    let month: Date

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(month, format: .dateTime.month(.wide).year())
                .font(.title3.weight(.semibold))
                .padding(.horizontal, 8)

            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol.uppercased())
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                ForEach(0..<leadingBlankDays, id: \.self) { _ in
                    Color.clear.frame(height: 44)
                }
                ForEach(days, id: \.self) { day in
                    DayCircle(date: day, status: store.status(on: day))
                }
            }
        }
        .padding(.vertical, 16)
    }

    /// Weekday headers starting at the locale's first weekday.
    private var weekdaySymbols: [String] {
        let symbols = calendar.shortWeekdaySymbols
        let first = calendar.firstWeekday - 1
        return Array(symbols[first...] + symbols[..<first])
    }

    private var days: [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: month) else { return [] }
        return range.compactMap { calendar.date(byAdding: .day, value: $0 - 1, to: month) }
    }

    /// Empty cells before day 1 so it lands under the right weekday.
    private var leadingBlankDays: Int {
        (calendar.component(.weekday, from: month) - calendar.firstWeekday + 7) % 7
    }
}

#Preview {
    NavigationStack {
        CalendarView()
    }
    .environment(LearningStore.preview(goal: .week))
}
