import SwiftUI

struct OnboardingView: View {
    @Environment(LearningStore.self) private var store
    @State private var subject = ""
    @State private var period: GoalPeriod = .week

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image(systemName: "flame.fill")
                .font(.system(size: 36))
                .foregroundStyle(Color.learnOrange)
                .frame(width: 109, height: 109)
                .glassEffect(.regular.tint(Color.learnOrange.opacity(0.15)), in: .circle)
                .frame(maxWidth: .infinity)
                .padding(.top, 40)

            Text("Hello \(Text("Learner").bold())")
                .font(.system(size: 34))
                .padding(.top, 50)

            Text("This app will help you learn everyday!")
                .font(.title3)
                .foregroundStyle(Color.secondaryLabel)
                .padding(.top, 4)

            GoalForm(subject: $subject, period: $period)
                .padding(.top, 31)

            Spacer()

            VStack(spacing: 12) {
                Button {
                    store.setGoal(subject: subject, period: period)
                } label: {
                    Text("Start Learning")
                        .font(.title3)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.glassProminent)
                .tint(.learnOrange)

                Text("You can edit your desire later")
                    .font(.footnote)
                    .foregroundStyle(Color.secondaryLabel)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 16)
        }
        .padding(.horizontal, 16)
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

#Preview {
    OnboardingView()
        .environment(LearningStore(defaults: UserDefaults(suiteName: "preview")!))
        .preferredColorScheme(.dark)
}
