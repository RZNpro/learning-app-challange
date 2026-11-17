import SwiftUI

/// "I want to learn" field plus the period picker. Shared by onboarding and the goal editor.
struct GoalForm: View {
    @Binding var subject: String
    @Binding var period: GoalPeriod

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("I want to learn")
                .font(.title3)
            TextField("Swift", text: $subject)
                .font(.title3)
                .autocorrectionDisabled()
                .padding(.top, 16)
                .padding(.bottom, 12)
            Divider()

            Text("I want to learn it in a")
                .font(.title3)
                .padding(.top, 24)
                .padding(.bottom, 12)
            Picker("Duration", selection: $period) {
                ForEach(GoalPeriod.allCases) { period in
                    Text(period.title).tag(period)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}

#Preview {
    GoalForm(subject: .constant(""), period: .constant(.week))
        .padding()
}
