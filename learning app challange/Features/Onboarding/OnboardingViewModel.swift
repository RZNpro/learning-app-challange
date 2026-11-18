import Foundation
import Observation

/// الـ ViewModel حق شاشة البداية (Onboarding). هذا حرف الـ VM في MVVM.
///
/// وظيفة الـ ViewModel: يشيل حالة الشاشة (وش كتب المستخدم ووش اختار)،
/// ويسوي الأفعال (لما يضغط زر). الـ View بس تعرض وتنادي دواله.
///
/// `@Observable` = لما يتغيّر `subject` أو `period`، الشاشة تتحدّث لحالها.
@Observable
final class OnboardingViewModel {
    // اللي يكتبه المستخدم في خانة "I want to learn". يبدأ فاضي.
    var subject = ""
    // المدة المختارة. الافتراضي أسبوع.
    var period: GoalPeriod = .week

    // المخزن. خليته `private` لأن الشاشة ما تحتاج توصل له، والـ ViewModel بس يكلّمه.
    private let store: LearningStore

    init(store: LearningStore) {
        self.store = store
    }

    /// هل أقدر أضغط "Start Learning"؟ بس لو كتبت موضوع (متطلب التحدي: Start Learning requires a topic).
    /// `trimmingCharacters` يشيل المسافات، عشان لو كتبت مسافات بس ما تنحسب موضوع.
    /// حطيت الشرط هنا في الـ ViewModel مو في الـ View، لأنه منطق، والـ View بس تعرض.
    var canStart: Bool {
        !subject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// لما أضغط "Start Learning": أحفظ الهدف في المخزن.
    /// وبعدها الـ RootView يلاحظ إن صار فيه هدف، فينقلني لشاشة Activity لحاله.
    func startLearning() {
        guard canStart else { return }   // حماية زيادة: بدون موضوع لا تسوي شي
        store.setGoal(subject: subject, period: period)
    }
}
