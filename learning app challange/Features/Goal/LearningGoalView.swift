import SwiftUI

/// Edits the current goal, or sets the next one once a goal has ended.
struct LearningGoalView: View {
    @State private var viewModel: LearningGoalViewModel
    @Environment(\.dismiss) private var dismiss

    init(store: LearningStore) {
        _viewModel = State(initialValue: LearningGoalViewModel(store: store))
    }

    var body: some View {
        GoalForm(subject: $viewModel.subject, period: $viewModel.period)
            .padding(.horizontal, 16)
            .padding(.top, 24)
            .frame(maxHeight: .infinity, alignment: .top)
            .navigationTitle("Learning Goal")
            .inlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", systemImage: "checkmark", action: viewModel.saveTapped)
                        .buttonStyle(.glassProminent)
                        .tint(.learnOrange)
                }
            }
            .alert("Update goal", isPresented: $viewModel.showsUpdateAlert) {
                Button("Dismiss", role: .cancel) {}
                Button("Update", action: viewModel.confirmUpdate)
            } message: {
                Text("If you update now, your streak will start over.")
            }
            .onChange(of: viewModel.isFinished) { _, isFinished in
                if isFinished { dismiss() }
            }
    }
}

#Preview {
    NavigationStack {
        LearningGoalView(store: .preview(goal: .week))
    }
}
