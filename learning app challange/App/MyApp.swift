import SwiftUI

/// نقطة البداية للتطبيق كله.
/// `@main` = يقول لـ Swift "من هنا يبدأ التطبيق". لازم يكون واحد بس في المشروع.
@main struct MyApp: App {
    /// المخزن ينخلق هنا مرة وحدة بس، وكل الشاشات تشاركه.
    /// `@State` = عشان يعيش طول ما التطبيق شغال وما ينخلق من جديد.
    @State private var store = LearningStore()

    var body: some Scene {
        // `WindowGroup` = نافذة التطبيق. أول شي يطلع فيها هو RootView.
        WindowGroup {
            RootView(store: store)
                // في نسخة التطوير بس: أعبّي داتا وهمية لثلاث أشهر عشان أشوف التقويم مليان.
                #if DEBUG
                .onAppear { SampleHistory.seedIfNeeded(store) }
                #endif
        }
    }
}
