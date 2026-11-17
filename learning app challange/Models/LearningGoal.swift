import Foundation

// ملف الـ Models: هنا "شكل البيانات" بس، بدون أي منطق عرض أو أزرار.
// هذا حرف الـ M في MVVM.

/// الهدف حقي: وش أبي أتعلم، وكم مدته، ومتى بديته.
///
/// سويته `struct` مو `class` لأنه مجرد بيانات بسيطة.
/// الـ struct نوع "قيمة" (Value Type): لو نسخته، كل نسخة مستقلة عن الثانية.
/// الـ class نوع "مرجع" (Reference Type): كل النسخ تأشر على نفس الشي، فلو تغيّر واحد تغيّر الكل.
///
/// `Codable` = أقدر أحوّله لـ JSON وأرجّعه، وهذا اللي يخليني أحفظه في الجهاز.
/// `Equatable` = أقدر أقارن هدفين ببعض بـ `==`.
struct LearningGoal: Codable, Equatable {
    var subject: String     // وش أتعلم، مثلاً "Swift"
    var period: GoalPeriod  // المدة: أسبوع أو شهر أو سنة
    var startDate: Date     // اليوم اللي بديت فيه الهدف

    // اليوم اللي بدأ فيه الستريك الحالي. يتغيّر لما ينقطع الستريك وأرجع أسجّل.
    // خليته Optional (`?`) عشان البيانات القديمة المحفوظة قبل ما أضيفه تنقرا عادي بدون ما يطيح التطبيق.
    var streakStart: Date?
    // آخر وقت بالضبط (بالساعة والدقيقة) سجلت فيه Learned أو Freeze.
    // منه أعرف إذا مرت 32 ساعة وانقطع الستريك.
    var lastActivity: Date?
}

/// مدة الهدف.
///
/// سويتها `enum` لأن الخيارات محددة ومعروفة (3 بس)، فما أقدر أكتب قيمة غلط بالغلط.
/// `String` = كل case له قيمة نصية ("week"…)، وهذا يسهّل الحفظ.
/// `CaseIterable` = يعطيني `allCases` (كل الخيارات)، أستخدمها في الـ Picker عشان يطلع الثلاث خيارات.
/// `Identifiable` = لازم يكون لكل عنصر `id` عشان `ForEach` يفرّق بينهم.
enum GoalPeriod: String, Codable, CaseIterable, Identifiable {
    case week, month, year

    // الـ id هو نفس الـ case، لأن كل case أصلاً مختلف عن الثاني.
    var id: Self { self }

    // النص اللي يطلع للمستخدم في الـ Picker.
    // هذي computed property: ما تنحفظ، تنحسب كل مرة أطلبها.
    var title: String {
        switch self {
        case .week: "Week"
        case .month: "Month"
        case .year: "Year"
        }
    }

    /// كم يوم يستمر الهدف. بعدها يخلص الهدف ويطلع لي إذا نجحت أو لا.
    var durationInDays: Int {
        switch self {
        case .week: 7
        case .month: 30
        case .year: 365
        }
    }

    /// كم مرة أقدر أجمّد (Freeze) خلال الهدف.
    var allowedFreezes: Int {
        switch self {
        case .week: 2
        case .month: 8
        case .year: 96
        }
    }
}

/// حالة اليوم: تعلمت فيه أو جمّدته.
/// ما فيه case ثالث لـ "ما سجلت"، لأن اليوم اللي ما سجلته ببساطة ما يكون موجود في السجل.
/// يعني ترجع `nil` (Optional): وهذا هو استخدام الـ Optional هنا.
enum DayStatus: String, Codable {
    case learned, freezed
}

/// وين وصل الهدف: لسا شغال، خلص ونجحت، أو خلص وما وصلت.
/// ما يحتاج `Codable` لأني ما أحفظه: أحسبه كل مرة من البيانات.
enum GoalOutcome {
    case inProgress, completed, notMet
}
