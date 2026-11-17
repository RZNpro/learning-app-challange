import SwiftUI

/// Shows onboarding exactly once — until the learner sets a first goal — then the Activity screen.
struct RootView: View {
    let store: LearningStore

    var body: some View {
        Group {
            if store.hasCompletedOnboarding {
                ActivityView(store: store)
            } else {
                OnboardingView(store: store)
            }
        }
        .transition(.opacity)
        .animation(.default, value: store.hasCompletedOnboarding)
    }
}

#Preview {
    RootView(store: .preview())
}
