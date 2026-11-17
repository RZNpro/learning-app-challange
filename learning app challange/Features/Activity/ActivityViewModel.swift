import Foundation
import Observation

/// الصفحات اللي أقدر أروح لها من شاشة Activity.
/// `enum` لأن الخيارات محددة (2 بس).
/// `Hashable` = شرط عشان أقدر أستخدمها في مسار التنقل (`NavigationStack`).
enum ActivityRoute: Hashable {
    case calendar, editGoal
}

/// وش يطلع في الشاشة لما يخلص الهدف: الأيقونة، والعنوان، والجملة الصغيرة تحته.
/// `struct` لأنها بيانات بسيطة للعرض بس.
struct GoalEndedContent {
    let icon: String
    let title: String
    let subtitle: String
}

/// الـ ViewModel حق الشاشة الرئيسية (Activity). هو أكبر ViewModel في التطبيق.
///
/// كل شي تحتاجه الشاشة يتجهّز هنا: النصوص، وحالة الأزرار، وأيام الأسبوع، والتنقل.
/// الـ View ما تفكّر ولا تحسب، بس تاخذ من هنا وتعرض.
@Observable
final class ActivityViewModel {
    // مسار التنقل. لما أضيف له صفحة، تنفتح. ولما أشيلها (زر الرجوع)، ترجع.
    var path: [ActivityRoute] = []

    private let store: LearningStore
    private let calendar = Calendar.current

    init(store: LearningStore) {
        self.store = store
    }

    // MARK: - العنوان

    // تاريخ اليوم بالشكل: "Tuesday, 17 November". يطلع تحت كلمة Activity.
    var dateText: String {
        store.today.formatted(.dateTime.weekday(.wide).day().month(.wide))
    }

    /// جملة الهدف مثل "Learning Swift this week".
    /// ترجع Optional (`String?`)، لأن لو ما فيه هدف ما أبي يطلع شي.
    /// `guard let goal = store.goal else { return nil }` = لو ما فيه هدف رجّع nil واطلع.
    var goalText: String? {
        guard let goal = store.goal else { return nil }
        return "Learning \(goal.subject) this \(goal.period.title.lowercased())"
    }

    // MARK: - شريط الأسبوع

    /// أيام الأسبوع السبعة (من الأحد للسبت) اللي فيها اليوم.
    /// كل يوم يرجع `DayItem` جاهز للعرض: التاريخ + حالته + هل هو اليوم.
    var weekDays: [DayItem] {
        guard let week = calendar.dateInterval(of: .weekOfYear, for: store.today) else { return [] }
        // من 0 إلى 6: أضيف كل رقم على أول يوم في الأسبوع، فيطلع لي الأيام السبعة.
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: week.start).map { dayItem(for: $0) }
        }
    }

    // أول حرف من اسم اليوم (S M T W…) اللي يطلع فوق كل دائرة.
    func weekdayLetter(for date: Date) -> String {
        date.formatted(.dateTime.weekday(.narrow))
    }

    // MARK: - العدادات

    // آخذها من المخزن كما هي. الشاشة ما تكلّم المخزن، تكلّمني أنا.
    var learnedCount: Int { store.learnedCount }
    var freezedCount: Int { store.freezedCount }

    // MARK: - اليوم

    var isGoalInProgress: Bool { store.outcome == .inProgress }

    // زر Log: يكون متاح إلا إذا سجلت اليوم Learned أصلاً.
    var canLogLearned: Bool { store.todayStatus != .learned }
    // النص يتغيّر حسب الحالة. سويته هنا مو في الـ View، لأن هذا "منطق عرض" ومكانه الـ ViewModel.
    var logButtonTitle: String { canLogLearned ? "Log as Learned" : "Logged as Learned" }

    // زر Freeze: القرار من المخزن (عنده القاعدة). أنا بس أوصّله للشاشة.
    var canFreeze: Bool { store.canFreezeToday }
    var freezeButtonTitle: String { store.todayStatus == .freezed ? "Freezed for a day" : "Freeze for a day" }
    var freezesUsedText: String { "\(store.freezedCount) out of \(store.allowedFreezes) Freezes used" }

    /// لو الهدف خلص، وش أعرض بدل أزرار التسجيل؟
    /// ترجع Optional: لو الهدف لسا شغال ترجع nil، والشاشة تعرض الأزرار العادية.
    /// `switch` على الـ enum لازم يغطي كل الحالات، وإلا Xcode يعطيني خطأ. وهذا يحميني من النسيان.
    var goalEndedContent: GoalEndedContent? {
        switch store.outcome {
        case .inProgress:
            nil
        case .completed:
            GoalEndedContent(icon: "hands.clap.fill", title: "Well done!", subtitle: "Ready for your next goal?")
        case .notMet:
            GoalEndedContent(icon: "xmark.seal", title: "You didn't reach your goal this time.", subtitle: "Want to set another goal?")
        }
    }

    // MARK: - الأفعال

    // لما أضغط الأزرار. الـ View تنادي هذي الدوال بس، والشغل الحقيقي في المخزن.
    func logLearned() { store.logLearnedToday() }
    func freeze() { store.freezeToday() }
    // التنقل: أضيف الصفحة للمسار فتنفتح.
    func showCalendar() { path.append(.calendar) }
    func showGoalEditor() { path.append(.editGoal) }

    // أجهّز يوم واحد للعرض. `private` لأنها مساعدة داخلية بس.
    private func dayItem(for date: Date) -> DayItem {
        DayItem(date: date, status: store.status(on: date), isToday: date == store.today)
    }
}
