import SwiftUI

/// Shows onboarding exactly once — until the learner sets a first goal — then the Activity screen.
struct RootView: View {
    @Environment(LearningStore.self) private var store

    var body: some View {
        Group {
            if store.hasCompletedOnboarding {
                ActivityView()
            } else {
                OnboardingView()
            }
        }
        .transition(.opacity)
        .animation(.default, value: store.hasCompletedOnboarding)
    }
}

#Preview {
    RootView()
        .environment(LearningStore.preview())
}
