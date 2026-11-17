#if DEBUG
import Foundation

/// داتا وهمية لثلاث أشهر قبل الشهر الحالي، عشان أشوف التقويم وإحصائية السنة مليانة وأنا أطوّر.
/// `#if DEBUG` = تدخل في نسخة التطوير بس. النسخة اللي تنزل للمستخدمين تبدأ فاضية.
///
/// سويتها `enum` بدون cases: حيلة معروفة في Swift لما أبي "مكان" أجمع فيه دوال static بس.
/// كذا محد يقدر يسوي منها نسخة بالغلط.
enum SampleHistory {
    private static let seededKey = "learningJourney.sampleHistorySeeded"
    private static let monthsBack = 3

    /// أعبّي الداتا مرة وحدة بس لكل تثبيت.
    /// أحفظ علامة في UserDefaults إني عبّيتها، فما تتكرر كل ما أفتح التطبيق.
    static func seedIfNeeded(_ store: LearningStore, defaults: UserDefaults = .standard) {
        guard !defaults.bool(forKey: seededKey) else { return }   // عبّيتها قبل؟ اطلع
        store.importHistory(entries())
        defaults.set(true, forKey: seededKey)
    }

    /// النمط ثابت ويتكرر: أغلب الأيام تعلمت، وكل 6 أيام تجميد، وكل 9 أيام يوم فايت.
    /// `%` = باقي القسمة. لو الرقم يقبل القسمة على 9، فهو اليوم التاسع.
    static func entries(calendar: Calendar = .current, now: Date = .now) -> [Date: DayStatus] {
        guard let thisMonth = calendar.dateInterval(of: .month, for: now)?.start,
              let firstDay = calendar.date(byAdding: .month, value: -monthsBack, to: thisMonth) else { return [:] }

        var entries: [Date: DayStatus] = [:]
        var day = firstDay
        var index = 0
        while day < thisMonth {
            index += 1
            let isMissed = index % 9 == 0
            if !isMissed {
                entries[day] = index % 6 == 0 ? .freezed : .learned
            }
            guard let next = calendar.date(byAdding: .day, value: 1, to: day) else { break }
            day = next
        }
        return entries
    }
}
#endif
