import SwiftUI

/// "Activities": this year's totals, then every month since the learner started.
struct CalendarView: View {
    @State private var viewModel: CalendarViewModel

    init(store: LearningStore) {
        _viewModel = State(initialValue: CalendarViewModel(store: store))
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    yearSummary
                        .padding(.horizontal, 4)
                        .padding(.bottom, 8)

                    ForEach(viewModel.months) { month in
                        MonthGrid(month: month, weekdaySymbols: viewModel.weekdaySymbols)
                            .id(month.id)
                        Divider()
                    }
                }
                .padding(.horizontal, 12)
            }
            .onAppear {
                proxy.scrollTo(viewModel.currentMonthID, anchor: .top)
            }
        }
        .navigationTitle("Activities")
        .inlineNavigationTitle()
    }

    /// Learned / freezed totals for the current calendar year, across all goals.
    private var yearSummary: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("This year")
                .font(.title3.weight(.semibold))
                .padding(.horizontal, 4)
            HStack(spacing: 12) {
                StatCard.learned(viewModel.learnedThisYear)
                StatCard.freezed(viewModel.freezedThisYear)
            }
        }
        .padding(.top, 16)
    }
}

/// One month laid out as a seven-column grid.
private struct MonthGrid: View {
    let month: CalendarMonth
    let weekdaySymbols: [String]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(month.title)
                .font(.title3.weight(.semibold))
                .padding(.horizontal, 8)

            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                ForEach(0..<month.leadingBlankDays, id: \.self) { _ in
                    Color.clear.frame(height: 44)
                }
                ForEach(month.days) { day in
                    DayCircle(day: day)
                }
            }
        }
        .padding(.vertical, 16)
    }
}

#Preview {
    NavigationStack {
        CalendarView(store: .preview(goal: .week))
    }
}
