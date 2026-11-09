import SwiftUI

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
                Button("Update") { applyAndClose() }
            } message: {
                Text("If you update now, your streak will start over.")
            }
            .onAppear {
                subject = store.goal?.subject ?? ""
                period = store.goal?.period ?? .week
            }
    }

    private func save() {
        // A finished goal has no streak to lose, so there's nothing to warn about.
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
    .environment(LearningStore(defaults: UserDefaults(suiteName: "preview")!))
    .preferredColorScheme(.dark)
}
