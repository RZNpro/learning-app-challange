import Foundation
import Observation

/// هذا "المخزن" حق التطبيق كله، والمصدر الوحيد للبيانات (Single Source of Truth).
///
/// فيه ثلاث مسؤوليات:
/// 1. يشيل البيانات: الهدف + سجل الأيام.
/// 2. يطبّق قواعد الهدف: كم يوم تعلمت، هل أقدر أجمّد، هل الهدف خلص…
/// 3. يحفظ كل شي في الجهاز (UserDefaults) عشان ما تضيع لو سكّرت التطبيق.
///
/// في MVVM هذا جزء من طبقة الـ Model (أو Service).
/// الـ ViewModels هي اللي تكلّمه، والـ Views ما تكلّمه مباشرة أبداً.
///
/// سويته `class` مو `struct` لأني أبي نسخة وحدة بس يشاركونها كل الشاشات.
/// لو كان struct، كل شاشة بتاخذ نسخة لحالها والبيانات ما بتتزامن.
///
/// `@Observable` = أي شاشة تقرأ من هنا تتحدّث تلقائياً لما تتغيّر البيانات.
/// `final` = محد يقدر يورث منه (Inheritance). ما احتجته، فقفلته.
@Observable
final class LearningStore {
    // شكل البيانات اللي أحفظها في الجهاز: الهدف + السجل مع بعض.
    // حطيته private لأن محد برا هالملف يحتاج يعرف عنه.
    private struct Snapshot: Codable {
        var goal: LearningGoal?
        var log: [Date: DayStatus]
    }

    // `static` = ثابت واحد يخص الـ class نفسه، مو كل نسخة منه.
    private static let storageKey = "learningJourney.snapshot"
    // متطلب السكتش: لو مرت أكثر من 32 ساعة بدون Learned ولا Freeze، الستريك يتصفّر.
    // `TimeInterval` = مدة بالثواني، فأكتبها 32 ساعة × 60 دقيقة × 60 ثانية.
    private static let streakTimeout: TimeInterval = 32 * 60 * 60
    private let defaults: UserDefaults
    private let calendar = Calendar.current
    // "الوقت الحالي". خليته دالة أمررها بدل ما أكتب `.now` مباشرة،
    // عشان في الاختبار أقدر أعطيه أي تاريخ أبيه وأجرب مثلاً لو مرت 32 ساعة، بدون ما أنتظر يومين.
    // `() -> Date` = Closure: دالة ما تاخذ شي وترجّع تاريخ.
    private let now: () -> Date

    /// الهدف الحالي.
    /// علامة `?` تعني Optional: ممكن يكون فيه قيمة، وممكن يكون `nil` (فاضي).
    /// يكون `nil` قبل ما أخلّص الـ Onboarding، وبعدها ما يرجع nil أبداً.
    ///
    /// `private(set)` = أي أحد يقدر يقرأه، بس التعديل من داخل هالـ class بس.
    /// كذا محد يغيّر الهدف من برا بالغلط.
    ///
    /// `didSet` = كود يشتغل تلقائياً بعد كل تغيير. هنا يحفظ على طول.
    private(set) var goal: LearningGoal? { didSet { save() } }

    /// سجل كل الأيام اللي سجلتها من أول ما بديت.
    /// نوعه Dictionary: المفتاح هو التاريخ، والقيمة حالة اليوم (learned أو freezed).
    /// ما ينمسح لما أغيّر الهدف، عشان التقويم وإحصائية السنة يعرضون كل تاريخي.
    private(set) var log: [Date: DayStatus] = [:] { didSet { save() } }

    /// الـ init يشتغل أول ما ينخلق المخزن: يقرأ البيانات المحفوظة لو موجودة.
    /// `defaults` و `now` لهم قيم افتراضية، فالتطبيق يناديه بدونهم.
    /// أمررهم بس في الـ Previews والاختبارات.
    /// `@escaping` = الـ closure ينحفظ ويُستخدم بعدين، مو بس داخل الـ init.
    init(defaults: UserDefaults = .standard, now: @escaping () -> Date = { .now }) {
        self.defaults = defaults
        self.now = now
        // `if let` = طريقة آمنة أفك فيها الـ Optional:
        // إذا فيه بيانات محفوظة وقدرت أقراها، ادخل وعبّي. وإذا لا، تجاهل وكمّل بدونها.
        // `try?` = جرّب الـ decode، ولو فشل رجّع nil بدل ما يطيح التطبيق.
        if let data = defaults.data(forKey: Self.storageKey),
           let snapshot = try? JSONDecoder().decode(Snapshot.self, from: data) {
            goal = snapshot.goal
            log = snapshot.log
        }
    }

    // MARK: - الأيام

    // بداية اليوم الحالي (الساعة 12 بالليل).
    // أستخدم بداية اليوم دائماً عشان كل تسجيلات نفس اليوم تكون بنفس المفتاح في السجل.
    var today: Date { calendar.startOfDay(for: now()) }

    // حالة اليوم. ترجع Optional، فإذا ما سجلت شي اليوم ترجع nil.
    var todayStatus: DayStatus? { log[today] }

    // حالة أي يوم. أستخدمها في شريط الأسبوع والتقويم.
    func status(on date: Date) -> DayStatus? {
        log[calendar.startOfDay(for: date)]
    }

    /// أول يوم مسجّل عندي. منه يبدأ التقويم يعرض الأشهر.
    /// `compactMap` تشيل الـ nil من المصفوفة.
    /// `??` اسمها Nil-Coalescing: "إذا طلعت nil، استخدم القيمة اللي بعدي". هنا يعني إذا ما فيه شي، خذ اليوم.
    var earliestRecordedDay: Date {
        (log.keys + [goal?.startDate].compactMap { $0 }).min() ?? today
    }

    // MARK: - الهدف الحالي

    // إذا فيه هدف، يعني خلصت الـ Onboarding. عشان كذا الـ Onboarding يطلع مرة وحدة بس.
    var hasCompletedOnboarding: Bool { goal != nil }

    /// الستريك: كم يوم تعلمت **ورا بعض بدون انقطاع**.
    /// يتصفّر في حالتين (متطلب السكتش):
    /// 1. لو مرت أكثر من 32 ساعة بدون Learned ولا Freeze.
    /// 2. لو غيّرت الهدف.
    /// مثال: هدف شهر، تعلمت يوم 2 ويوم 12 بس. يوم 12 الستريك = 1، لأن اللي بينهم انقطاع.
    ///
    /// لو الهدف خلص (نجحت أو لا)، أعرض الرقم النهائي ولا أصفّره، عشان المستخدم يشوف وش وصل له.
    var learnedCount: Int {
        if outcome == .inProgress && isStreakBroken { return 0 }
        return streakLog.values.count(where: { $0 == .learned })
    }

    /// كم Freeze استخدمت في الهدف كله. هذا رصيد للهدف، ما يتصفّر لو انقطع الستريك.
    /// لو صفّرته مع الستريك، كان المستخدم بياخذ Freezes زيادة على المسموح.
    var freezedCount: Int { goalLog.values.count(where: { $0 == .freezed }) }

    /// هل انقطع الستريك؟ يعني مرت أكثر من 32 ساعة من آخر تسجيل.
    var isStreakBroken: Bool {
        guard let goal else { return false }
        // البيانات القديمة (قبل ما أضيف `lastActivity`) ما فيها وقت آخر تسجيل،
        // فأفترض إنه كان آخر لحظة في آخر يوم مسجّل. ولو ما فيه ولا يوم، من بداية الهدف.
        // `flatMap` = لو فيه قيمة طبّق عليها الدالة، ولو nil خلّها nil.
        let lastActivity = goal.lastActivity
            ?? goalLog.keys.max().flatMap { calendar.date(byAdding: .day, value: 1, to: $0) }
            ?? goal.startDate
        return now().timeIntervalSince(lastActivity) > Self.streakTimeout
    }

    // `goal?.period` اسمها Optional Chaining:
    // إذا الهدف nil، توقف وطلّع nil بدون كراش. وبعدها `?? 0` يحوّل الـ nil إلى صفر.
    var allowedFreezes: Int { goal?.period.allowedFreezes ?? 0 }

    /// هل أقدر أضغط Freeze اليوم؟
    /// أقدر أجمّد حتى لو سجلت Learned، عشان المستخدم يبدّل بين الاثنين براحته (طلب المعلم).
    /// الشرطين: اليوم مو مجمّد أصلاً + باقي عندي رصيد Freeze.
    var canFreezeToday: Bool { todayStatus != .freezed && freezedCount < allowedFreezes }

    /// وين وصل الهدف؟
    /// - **نجحت (.completed):** أول ما يوصل الستريك لمدة الهدف (7 أو 30 أو 365 يوم).
    ///   الـ Freeze يحسب من أيام الستريك، لأنه يحافظ عليه. مثلاً أسبوع = 5 تعلم + 2 Freeze.
    ///   تطلع "Well done" في نفس اليوم اللي أكمل فيه، مو اليوم اللي بعده.
    /// - **ما وصلت (.notMet):** لو خلصت مدة الهدف والستريك ما وصل.
    /// - **غير كذا:** لسا شغال (.inProgress).
    ///
    /// `guard` = "تأكد من الشرط، ولو ما تحقق اطلع على طول".
    var outcome: GoalOutcome {
        guard let goal, let end = endDate(of: goal) else { return .inProgress }
        if streakLog.count >= goal.period.durationInDays { return .completed }
        return today >= end ? .notMet : .inProgress
    }

    // الأيام اللي داخل فترة الهدف الحالي بس، من يوم البداية لين يوم النهاية.
    private var goalLog: [Date: DayStatus] {
        guard let goal, let end = endDate(of: goal) else { return [:] }
        let start = calendar.startOfDay(for: goal.startDate)
        return log.filter { (start..<end).contains($0.key) }
    }

    // أيام الستريك الحالي بس: من يوم ما بدأ الستريك لين اليوم.
    // لو ما فيه بداية محفوظة (بيانات قديمة)، أبدأ من بداية الهدف.
    private var streakLog: [Date: DayStatus] {
        guard let goal else { return [:] }
        let start = calendar.startOfDay(for: goal.streakStart ?? goal.startDate)
        return goalLog.filter { $0.key >= start }
    }

    // يوم نهاية الهدف = يوم البداية + مدة الهدف.
    private func endDate(of goal: LearningGoal) -> Date? {
        calendar.date(byAdding: .day, value: goal.period.durationInDays, to: calendar.startOfDay(for: goal.startDate))
    }

    // MARK: - التاريخ

    /// مجموع أيام التعلم والتجميد في السنة كلها، لكل الأهداف.
    /// هذي اللي تطلع في صفحة التقويم تحت "This year".
    /// ترجع Tuple: قيمتين مع بعض، ولكل وحدة اسم (learned و freezed).
    func totals(inYearOf date: Date) -> (learned: Int, freezed: Int) {
        let yearLog = log.filter { calendar.isDate($0.key, equalTo: date, toGranularity: .year) }
        return (yearLog.values.count(where: { $0 == .learned }), yearLog.values.count(where: { $0 == .freezed }))
    }

    // MARK: - الأفعال (Actions)

    /// أبدأ هدف جديد من اليوم.
    func setGoal(subject: String, period: GoalPeriod) {
        // لو غيّرت الهدف وهو لسا شغال، أمسح تسجيل اليوم عشان أبدأ من الصفر فعلاً،
        // مثل ما وعد التنبيه: "your streak will start over".
        // الأيام اللي قبل تبقى في التقويم عادي، ما ينمسح غير اليوم.
        if goal != nil, outcome == .inProgress {
            log[today] = nil
        }
        // أشيل المسافات الزايدة. ولو المستخدم ما كتب شي، أحط "Swift" بدالها.
        let trimmed = subject.trimmingCharacters(in: .whitespacesAndNewlines)
        // الستريك يبدأ من اليوم، وعداد الـ 32 ساعة يبدأ من الحين.
        goal = LearningGoal(
            subject: trimmed.isEmpty ? "Swift" : trimmed,
            period: period,
            startDate: today,
            streakStart: today,
            lastActivity: now()
        )
    }

    /// أسجّل اليوم "تعلمت".
    /// لو كان مجمّد، يتحول لتعلّم، والـ Freeze يرجع لرصيدي تلقائياً لأن العداد يحسب من السجل.
    func logLearnedToday() {
        guard todayStatus != .learned else { return }   // مسجّل أصلاً؟ لا تسوي شي
        recordActivity()
        log[today] = .learned
    }

    /// أجمّد اليوم. ولو كان مسجّل Learned يتحول لتجميد (التبديل بين الاثنين).
    func freezeToday() {
        guard canFreezeToday else { return }
        recordActivity()
        log[today] = .freezed
    }

    /// أناديها مع كل تسجيل (Learned أو Freeze).
    /// - لو الستريك منقطع (مرت 32 ساعة)، أبدأ ستريك جديد من اليوم.
    /// - وبعدها أحدّث "آخر نشاط" للحين، فيبدأ عداد الـ 32 ساعة من جديد.
    /// `var updated = goal` = آخذ نسخة من الهدف (لأنه struct)، أعدّلها، وأرجّعها مرة وحدة.
    private func recordActivity() {
        guard var updated = goal else { return }
        if isStreakBroken {
            updated.streakStart = today
        }
        updated.lastActivity = now()
        goal = updated
    }

    /// أضيف أيام قديمة للسجل بدون ما أمسح أي يوم سجلته أنا. أستخدمها للداتا الوهمية.
    /// `merge` مع `{ existing, _ in existing }` = لو اليوم موجود، خلّ القديم وتجاهل الجديد.
    func importHistory(_ entries: [Date: DayStatus]) {
        let normalized = Dictionary(entries.map { (calendar.startOfDay(for: $0.key), $0.value) }) { first, _ in first }
        log.merge(normalized) { existing, _ in existing }
    }

    // MARK: - الحفظ

    // أحوّل البيانات لـ JSON وأحفظها في UserDefaults.
    // UserDefaults مكان صغير في الجهاز يناسب البيانات الخفيفة مثل هذي.
    private func save() {
        guard let data = try? JSONEncoder().encode(Snapshot(goal: goal, log: log)) else { return }
        defaults.set(data, forKey: Self.storageKey)
    }
}
