import SwiftUI

/// Screens reachable from the Activity header.
enum ActivityRoute: Hashable {
    case calendar, editGoal
}

/// Main screen: this week's progress and today's log actions.
struct ActivityView: View {
    @Environment(LearningStore.self) private var store
    @State private var path: [ActivityRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                ActivityHeader(path: $path)

                WeekStrip()
                    .padding(.top, 20)

                HStack(spacing: 12) {
                    StatCard.learned(store.learnedCount)
                    StatCard.freezed(store.freezedCount)
                }
                .padding(.top, 12)

                content
            }
            .padding(.horizontal, 16)
            .hiddenNavigationBar()
            .navigationDestination(for: ActivityRoute.self) { route in
                switch route {
                case .calendar: CalendarView()
                case .editGoal: LearningGoalView()
                }
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch store.outcome {
        case .inProgress:
            LogTodaySection()
        case .completed:
            GoalEndedView(icon: "hands.clap.fill",
                          title: "Well done!",
                          subtitle: "Ready for your next goal?") { path.append(.editGoal) }
        case .notMet:
            GoalEndedView(icon: "xmark.seal",
                          title: "You didn't reach your goal this time.",
                          subtitle: "Want to set another goal?") { path.append(.editGoal) }
        }
    }
}

/// Title, today's date, the goal being worked on, and the calendar / edit buttons.
private struct ActivityHeader: View {
    @Environment(LearningStore.self) private var store
    @Binding var path: [ActivityRoute]

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Activity")
                    .font(.largeTitle.bold())
                Text(store.today, format: .dateTime.weekday(.wide).day().month(.wide))
                    .font(.title3)
                    .foregroundStyle(.secondary)
                if let goal = store.goal {
                    Label("Learning \(goal.subject) this \(goal.period.title.lowercased())", systemImage: "target")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.learnOrange)
                }
            }

            Spacer()

            HStack(spacing: 12) {
                CircleIconButton(systemName: "calendar", accessibilityLabel: "Calendar") {
                    path.append(.calendar)
                }
                CircleIconButton(systemName: "pencil.and.outline", accessibilityLabel: "Edit goal") {
                    path.append(.editGoal)
                }
            }
        }
        .padding(.top, 8)
    }
}

/// The seven days of the current week, colored by how each was logged.
private struct WeekStrip: View {
    @Environment(LearningStore.self) private var store

    var body: some View {
        HStack(spacing: 0) {
            ForEach(store.currentWeek, id: \.self) { day in
                VStack(spacing: 6) {
                    Text(day, format: .dateTime.weekday(.narrow))
                        .font(.subheadline.weight(.semibold))
                    DayCircle(date: day, status: store.status(on: day), isToday: day == store.today)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

/// Big "Log as Learned" circle and the "Freeze for a day" button.
private struct LogTodaySection: View {
    @Environment(LearningStore.self) private var store

    private var isLearned: Bool { store.todayStatus == .learned }
    private var isFreezed: Bool { store.todayStatus == .freezed }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            logButton
            Spacer()
            freezeButton
            Text("\(store.freezedCount) out of \(store.allowedFreezes) Freezes used")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.top, 14)
                .padding(.bottom, 24)
        }
    }

    private var logButton: some View {
        Button {
            withAnimation(.snappy) { store.logLearnedToday() }
        } label: {
            Text(isLearned ? "Logged as Learned" : "Log as Learned")
                .font(.title3.bold())
                .multilineTextAlignment(.center)
                .foregroundStyle(isLearned ? Color.secondary : .white)
                .frame(width: 274, height: 274)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.tint(isLearned ? .mutedFill : .learnOrange).interactive(), in: .circle)
        .disabled(isLearned)
    }

    private var freezeButton: some View {
        Button {
            withAnimation(.snappy) { store.freezeToday() }
        } label: {
            Text(isFreezed ? "Freezed for a day" : "Freeze for a day")
                .font(.title3)
                .foregroundStyle(store.canFreeze ? Color.white : .secondary)
                .frame(width: 240)
                .padding(.vertical, 8)
        }
        .buttonStyle(.glassProminent)
        .tint(store.canFreeze ? .freezeCyan : .mutedFill)
        .disabled(!store.canFreeze)
    }
}

/// Shown when the goal period is over, whether or not it was met.
private struct GoalEndedView: View {
    let icon: String
    let title: String
    let subtitle: String
    let setGoal: () -> Void

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundStyle(.learnOrange)
                .padding(.bottom, 12)
            Text(title)
                .font(.headline)
                .multilineTextAlignment(.center)
            Text(subtitle)
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
    ActivityView()
        .environment(LearningStore.preview(goal: .week))
}
