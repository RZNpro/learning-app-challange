import SwiftUI

/// Main screen: this week's progress and today's log actions.
struct ActivityView: View {
    @State private var viewModel: ActivityViewModel
    private let store: LearningStore

    init(store: LearningStore) {
        self.store = store
        _viewModel = State(initialValue: ActivityViewModel(store: store))
    }

    var body: some View {
        NavigationStack(path: $viewModel.path) {
            VStack(spacing: 0) {
                if let goalText = viewModel.goalText {
                    Label(goalText, systemImage: "target")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.learnOrange)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                WeekStrip(viewModel: viewModel)
                    .padding(.top, 16)

                HStack(spacing: 12) {
                    StatCard.learned(viewModel.learnedCount)
                    StatCard.freezed(viewModel.freezedCount)
                }
                .padding(.top, 12)

                if let ended = viewModel.goalEndedContent {
                    GoalEndedView(content: ended, setGoal: viewModel.showGoalEditor)
                } else {
                    LogTodaySection(viewModel: viewModel)
                }
            }
            .padding(.horizontal, 16)
            .navigationTitle("Activity")
            .navigationSubtitle(viewModel.dateText)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Calendar", systemImage: "calendar", action: viewModel.showCalendar)
                }
                ToolbarSpacer(.fixed, placement: .primaryAction)
                ToolbarItem(placement: .primaryAction) {
                    Button("Edit goal", systemImage: "pencil.and.outline", action: viewModel.showGoalEditor)
                }
            }
            .navigationDestination(for: ActivityRoute.self) { route in
                switch route {
                case .calendar: CalendarView(store: store)
                case .editGoal: LearningGoalView(store: store)
                }
            }
        }
    }
}

/// The seven days of the current week, colored by how each was logged.
private struct WeekStrip: View {
    let viewModel: ActivityViewModel

    var body: some View {
        HStack(spacing: 0) {
            ForEach(viewModel.weekDays) { day in
                VStack(spacing: 6) {
                    Text(viewModel.weekdayLetter(for: day.date))
                        .font(.subheadline.weight(.semibold))
                    DayCircle(day: day)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

/// Big "Log as Learned" circle and the "Freeze for a day" button.
private struct LogTodaySection: View {
    let viewModel: ActivityViewModel

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            logButton
            Spacer()
            freezeButton
            Text(viewModel.freezesUsedText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.top, 14)
                .padding(.bottom, 24)
        }
    }

    private var logButton: some View {
        Button {
            withAnimation(.snappy) { viewModel.logLearned() }
        } label: {
            Text(viewModel.logButtonTitle)
                .font(.title3.bold())
                .foregroundStyle(viewModel.canLogLearned ? Color.white : .secondary)
                .frame(width: 250, height: 250)
        }
        .glassButtonStyle(isProminent: viewModel.canLogLearned)
        .buttonBorderShape(.circle)
        .tint(.learnOrange)
        .allowsHitTesting(viewModel.canLogLearned)
    }

    private var freezeButton: some View {
        Button {
            withAnimation(.snappy) { viewModel.freeze() }
        } label: {
            Text(viewModel.freezeButtonTitle)
                .font(.title3)
                .foregroundStyle(viewModel.canFreeze ? Color.white : .secondary)
                .frame(width: 240)
                .padding(.vertical, 8)
        }
        .glassButtonStyle(isProminent: viewModel.canFreeze)
        .buttonBorderShape(.capsule)
        .tint(.freezeCyan)
        .allowsHitTesting(viewModel.canFreeze)
    }
}

/// Shown when the goal period is over, whether or not it was met.
private struct GoalEndedView: View {
    let content: GoalEndedContent
    let setGoal: () -> Void

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: content.icon)
                .font(.system(size: 40))
                .foregroundStyle(.learnOrange)
                .padding(.bottom, 12)
            Text(content.title)
                .font(.headline)
                .multilineTextAlignment(.center)
            Text(content.subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button(action: setGoal) {
                Label("Set a goal", systemImage: "pencil.and.outline")
                    .font(.title3)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.glassProminent)
            .tint(.learnOrange)
            .padding(.top, 70)
        }
        .padding(.top, 70)
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    ActivityView(store: .preview(goal: .week))
}
