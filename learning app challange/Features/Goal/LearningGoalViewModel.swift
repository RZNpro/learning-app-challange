import Foundation
import Observation

/// الـ ViewModel حق شاشة تعديل الهدف (Learning Goal).
/// أستخدمها لما أعدّل الهدف الحالي، أو لما أحط هدف جديد بعد ما يخلص القديم.
@Observable
final class LearningGoalViewModel {
    var subject: String
    var period: GoalPeriod
    // هل يطلع تنبيه "Update goal"؟ الـ View تربطه بالـ alert، فلما يصير true يطلع التنبيه.
    var showsUpdateAlert = false
    /// يصير true بعد ما أحفظ، وهو اللي يقول للشاشة "سكّري وارجعي".
    /// `private(set)` = الشاشة تقراه بس، وما تقدر تغيّره.
    private(set) var isFinished = false

    private let store: LearningStore

    init(store: LearningStore) {
        self.store = store
        // أعبّي الخانات بالهدف الحالي عشان المستخدم يشوف وش اختار قبل.
        // `store.goal?.subject` = Optional Chaining (لو ما فيه هدف ترجع nil بدون كراش)،
        // و `?? ""` = لو طلعت nil حط نص فاضي بدالها.
        subject = store.goal?.subject ?? ""
        period = store.goal?.period ?? .week
    }

    /// لما أضغط زر ✓ (Save).
    func saveTapped() {
        // لو الهدف لسا شغال، أحذّر المستخدم إن الستريك بيتصفّر.
        // ولو الهدف خلص أصلاً ما فيه شي يضيع، فأحفظ على طول بدون تنبيه.
        if store.outcome == .inProgress {
            showsUpdateAlert = true
        } else {
            confirmUpdate()
        }
    }

    /// لما أضغط "Update" في التنبيه، أو مباشرة لو الهدف خلص.
    func confirmUpdate() {
        store.setGoal(subject: subject, period: period)
        isFinished = true   // الشاشة تلاحظ هالتغيير وترجع للصفحة اللي قبل
    }
}
