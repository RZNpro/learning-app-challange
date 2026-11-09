import SwiftUI

enum Route: Hashable {
    case calendar, editGoal
}

struct ActivityView: View {
    @Environment(LearningStore.self) private var store
    @State private var path: [Route] = []

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                header
                WeekStrip()
                    .padding(.top, 20)
                HStack(spacing: 12) {
                    StatCard(icon: "flame.fill", tint: .learnOrange, count: store.learnedCount, label: "Learned")
                    StatCard(icon: "snowflake", tint: .freezeCyan, count: store.freezedCount, label: "Freezed")
                }
                .padding(.top, 12)

                switch store.outcome {
                case .inProgress:
                    logSection
                case .completed:
                    GoalEndedView(icon: "hands.clap.fill", title: "Well done!", subtitle: "Ready for your next goal?") {
                        path.append(.editGoal)
                    }
                case .notMet:
                    GoalEndedView(icon: "xmark.seal", title: "You didn't reach your goal this time.", subtitle: "Want to set another goal?") {
                        path.append(.editGoal)
                    }
                }
            }
            .padding(.horizontal, 16)
            .hiddenNavigationBar()
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .calendar: CalendarView()
                case .editGoal: LearningGoalView()
                }
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Activity")
                    .font(.largeTitle.bold())
                Text(store.today, format: .dateTime.weekday(.wide).day().month(.wide))
                    .font(.title3)
                    .foregroundStyle(Color.secondaryLabel)
            }
            Spacer()
            HStack(spacing: 12) {
                CircleIconButton(systemName: "calendar") { path.append(.calendar) }
                CircleIconButton(systemName: "pencil.and.outline") { path.append(.editGoal) }
            }
        }
        .padding(.top, 8)
    }

    private var logSection: some View {
        VStack(spacing: 0) {
            Spacer()
            let learned = store.todayStatus == .learned
            Button {
                withAnimation(.snappy) { store.logLearnedToday() }
            } label: {
                Text(learned ? "Logged as Learned" : "Log as Learned")
                    .font(.system(size: 36, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(learned ? Color.secondaryLabel : .white)
                    .frame(width: 274, height: 274)
            }
            .buttonStyle(.plain)
            .glassEffect(.regular.tint(learned ? Color.mutedFill : Color.learnOrange).interactive(), in: .circle)
            .disabled(learned)

            Spacer()

            Button {
                withAnimation(.snappy) { store.freezeToday() }
            } label: {
                Text(store.todayStatus == .freezed ? "Freezed for a day" : "Freeze for a day")
                    .font(.title3)
                    .foregroundStyle(store.canFreeze ? .white : Color.secondaryLabel)
                    .frame(width: 240)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.glassProminent)
            .tint(store.canFreeze ? .freezeCyan : .mutedFill)
            .disabled(!store.canFreeze)

            Text("\(store.freezedCount) out of \(store.allowedFreezes) Freezes used")
                .font(.subheadline)
                .foregroundStyle(Color.secondaryLabel)
                .padding(.top, 14)
                .padding(.bottom, 24)
        }
    }
}

// MARK: - Components

private struct CircleIconButton: View {
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: .circle)
    }
}

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

/// A day number styled by its log status. Shared by the week strip and the calendar.
struct DayCircle: View {
    let date: Date
    let status: DayStatus?
    var isToday = false

    var body: some View {
        Text(date, format: .dateTime.day())
            .font(.title2.weight(isToday && status == nil ? .bold : .medium))
            .foregroundStyle(foreground)
            .frame(width: 44, height: 44)
            .background(background, in: .circle)
    }

    private var foreground: Color {
        switch status {
        case .learned: .learnOrange
        case .freezed: .freezeCyan
        case nil: .white
        }
    }

    private var background: Color {
        switch status {
        case .learned: .learnOrange.opacity(0.18)
        case .freezed: .freezeCyan.opacity(0.15)
        case nil: isToday ? .learnOrange : .clear
        }
    }
}

private struct StatCard: View {
    let icon: String
    let tint: Color
    let count: Int
    let label: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(tint)
            Text("\(count) \(count == 1 ? "day" : "days")")
                .font(.title3.bold())
            Text(label)
                .font(.footnote)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .glassEffect(.regular.tint(Color.cardBackground), in: .rect(cornerRadius: 34))
    }
}

private struct GoalEndedView: View {
    let icon: String
    let title: String
    let subtitle: String
    let setGoal: () -> Void

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundStyle(Color.learnOrange)
                .padding(.bottom, 12)
            Text(title)
                .font(.headline)
                .multilineTextAlignment(.center)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(Color.secondaryLabel)

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
    let store = LearningStore(defaults: UserDefaults(suiteName: "preview")!)
    store.setGoal(subject: "Swift", period: .week)
    return ActivityView()
        .environment(store)
        .preferredColorScheme(.dark)
}
