import SwiftUI

/// Shows onboarding until the learner sets a first goal, then the Activity screen.
struct ContentView: View {
    @Environment(LearningStore.self) private var store

    var body: some View {
        Group {
            if store.goal == nil {
                OnboardingView()
                    .transition(.opacity)
            } else {
                ActivityView()
                    .transition(.opacity)
            }
        }
        .animation(.default, value: store.goal == nil)
        .tint(.learnOrange)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
        .environment(LearningStore(defaults: UserDefaults(suiteName: "preview")!))
}
