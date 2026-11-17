import SwiftUI

/// المشروع يدعم أكثر من منصة (iPhone و Mac و Vision Pro).
/// بعض الأوامر موجودة في iOS بس، فحطيتها هنا عشان المشروع ما يعطي خطأ في المنصات الثانية.
extension View {
    /// يخلي عنوان الصفحة صغير وبالنص (مثل "Learning Goal" و "Activities").
    /// `#if os(iOS)` = هالسطر يدخل بس لما أبني للآيفون. في غيره، رجّع الشاشة زي ما هي (`self`).
    func inlineNavigationTitle() -> some View {
        #if os(iOS)
        navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }
}
