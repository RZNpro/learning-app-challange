#if DEBUG
import Foundation

// `#if DEBUG` = هالكود يدخل في نسخة التطوير بس، وما يوصل للنسخة اللي تنزل للمستخدمين.

// `extension` = أضيف شي على class موجود بدون ما ألمس الملف الأصلي.
// هنا أضفت للمخزن دالة تسوي لي مخزن تجريبي للـ Previews.
extension LearningStore {
    /// مخزن وهمي للـ `#Preview` (المعاينة الحية في Xcode).
    /// يحفظ في مكان مؤقت جديد كل مرة (UUID)، عشان المعاينة ما تخرّب بياناتي الحقيقية.
    /// إذا عطيته مدة، يسوي هدف "Swift" ويعبّي داتا وهمية عشان أشوف الشاشة مليانة.
    ///
    /// `static func` = أناديها من النوع نفسه بدون نسخة: `LearningStore.preview()` أو `.preview()`.
    static func preview(goal period: GoalPeriod? = nil) -> LearningStore {
        let store = LearningStore(defaults: UserDefaults(suiteName: "preview-\(UUID())")!)
        if let period {   // `if let period` = لو المدة مو nil، فكّها واستخدمها
            store.setGoal(subject: "Swift", period: period)
            store.importHistory(SampleHistory.entries())
        }
        return store
    }
}
#endif
