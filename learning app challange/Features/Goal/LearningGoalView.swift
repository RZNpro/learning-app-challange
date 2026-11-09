import SwiftUI

/// Edits the current goal, or sets the next one once a goal has ended.
struct LearningGoalView: View {
    @Environment(LearningStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var subject = ""
    @State private var period: GoalPeriod = .week
    @State private var showsUpdateAlert = false

    var body: some View {
        GoalForm(subject: $subject, period: $period)
            .padding(.horizontal, 16)
            .padding(.top, 24)
            .frame(maxHeight: .infinity, alignment: .top)
            .navigationTitle("Learning Goal")
            .inlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", systemImage: "checkmark", action: save)
                        .buttonStyle(.glassProminent)
                        .tint(.learnOrange)
                }
            }
            .alert("Update goal", isPresented: $showsUpdateAlert) {
                Button("Dismiss", role: .cancel) {}
                Button("Update", action: applyAndClose)
            } message: {
                Text("If you update now, your streak will start over.")
            }
            .onAppear(perform: loadCurrentGoal)
    }

    private func loadCurrentGoal() {
        subject = store.goal?.subject ?? ""
        period = store.goal?.period ?? .week
    }

    private func save() {
        // A finished goal has no streak left to lose, so there is nothing to warn about.
        if store.outcome == .inProgress {
            showsUpdateAlert = true
        } else {
            applyAndClose()
        }
    }

    private func applyAndClose() {
        store.setGoal(subject: subject, period: period)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        LearningGoalView()
    }
    .environment(LearningStore.preview(goal: .week))
}
