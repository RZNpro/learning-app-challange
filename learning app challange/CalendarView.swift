import SwiftUI

/// "Activities" screen: every month since the learner started, with learned/freezed days highlighted.
struct CalendarView: View {
    @Environment(LearningStore.self) private var store

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
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
                        .foregroundStyle(Color.secondaryLabel)
                }
                ForEach(0..<leadingBlanks, id: \.self) { _ in
                    Color.clear.frame(height: 44)
                }
                ForEach(days, id: \.self) { day in
                    DayCircle(date: day, status: store.status(on: day))
                }
            }
        }
        .padding(.vertical, 16)
    }

    /// Weekday headers ordered to start at the locale's first weekday.
    private var weekdaySymbols: [String] {
        let symbols = calendar.shortWeekdaySymbols
        let first = calendar.firstWeekday - 1
        return Array(symbols[first...] + symbols[..<first])
    }

    private var days: [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: month) else { return [] }
        return range.compactMap { calendar.date(byAdding: .day, value: $0 - 1, to: month) }
    }

    private var leadingBlanks: Int {
        (calendar.component(.weekday, from: month) - calendar.firstWeekday + 7) % 7
    }
}

#Preview {
    NavigationStack {
        CalendarView()
    }
    .environment(LearningStore(defaults: UserDefaults(suiteName: "preview")!))
    .preferredColorScheme(.dark)
}
