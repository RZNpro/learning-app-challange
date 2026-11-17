import SwiftUI

/// أول شاشة "حقيقية". تقرر وش يطلع:
/// لو ما عندي هدف تطلع الـ Onboarding، ولو عندي تطلع الـ Activity.
/// وبما إن الهدف ما ينحذف بعد أول مرة، فالـ Onboarding يطلع مرة وحدة بس.
struct RootView: View {
    // `let` = ثابت ما يتغيّر. المخزن نفسه ثابت، بس البيانات اللي داخله تتغيّر عادي.
    let store: LearningStore

    var body: some View {
        // `Group` = يجمع أكثر من View عشان أحط عليهم نفس الـ modifiers.
        Group {
            if store.hasCompletedOnboarding {
                ActivityView(store: store)
            } else {
                OnboardingView(store: store)
            }
        }
        // لما ينتقل من Onboarding لـ Activity، يصير تلاشي ناعم بدل ما تنقلب الشاشة فجأة.
        .transition(.opacity)
        .animation(.default, value: store.hasCompletedOnboarding)
    }
}

#Preview {
    RootView(store: .preview())
}
