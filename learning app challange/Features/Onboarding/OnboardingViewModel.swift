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

    /// لما أضغط "Start Learning": أحفظ الهدف في المخزن.
    /// وبعدها الـ RootView يلاحظ إن صار فيه هدف، فينقلني لشاشة Activity لحاله.
    func startLearning() {
        store.setGoal(subject: subject, period: period)
    }
}
