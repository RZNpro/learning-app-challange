import Foundation
import Observation

/// شهر واحد في التقويم، جاهز للعرض.
/// `Identifiable` عشان `ForEach` يفرّق بين الأشهر. والـ id هو أول يوم في الشهر، لأنه ما يتكرر.
struct CalendarMonth: Identifiable {
    let firstDay: Date
    let title: String          // مثل "November 2026"
    /// كم خانة فاضية قبل يوم 1، عشان يطلع تحت اسم اليوم الصحيح.
    /// مثلاً لو الشهر يبدأ يوم الثلاثاء، أحط خانتين فاضيات (الأحد والاثنين).
    let leadingBlankDays: Int
    let days: [DayItem]

    var id: Date { firstDay }
}

/// الـ ViewModel حق صفحة التقويم (Activities).
/// كل حسابات التقويم هنا، والـ View بس ترسم اللي أعطيها.
@Observable
final class CalendarViewModel {
    private let store: LearningStore
    private let calendar = Calendar.current

    init(store: LearningStore) {
        self.store = store
    }

    // مجموع السنة كلها، لكل الأهداف. يطلع فوق تحت "This year".
    var learnedThisYear: Int { store.totals(inYearOf: store.today).learned }
    var freezedThisYear: Int { store.totals(inYearOf: store.today).freezed }

    /// أسماء الأيام (SUN MON TUE…) مرتبة حسب أول يوم في الأسبوع بإعدادات الجهاز.
    /// في بعض الدول الأسبوع يبدأ الاثنين، فأرتبها حسب الجهاز عشان ما تطلع غلط.
    var weekdaySymbols: [String] {
        let symbols = calendar.shortWeekdaySymbols.map { $0.uppercased() }
        let first = calendar.firstWeekday - 1
        return Array(symbols[first...] + symbols[..<first])
    }

    /// كل الأشهر من أول يوم سجلته لين الشهر الحالي.
    var months: [CalendarMonth] {
        // `guard var` و `guard let`: لو ما قدرت أحسب البداية أو النهاية، أرجّع مصفوفة فاضية.
        guard var monthStart = calendar.dateInterval(of: .month, for: store.earliestRecordedDay)?.start,
              let lastMonth = calendar.dateInterval(of: .month, for: store.today)?.start else { return [] }

        var months: [CalendarMonth] = []
        // `while` = كرّر لين أوصل الشهر الحالي، وكل لفة أضيف شهر.
        while monthStart <= lastMonth {
            months.append(month(startingAt: monthStart))
            guard let next = calendar.date(byAdding: .month, value: 1, to: monthStart) else { break }
            monthStart = next
        }
        return months
    }

    /// الشهر اللي تفتح عليه الصفحة (الشهر الحالي)، بدل ما أبدأ من أقدم شهر وأنزل.
    var currentMonthID: Date? {
        calendar.dateInterval(of: .month, for: store.today)?.start
    }

    // أجهّز شهر واحد: عنوانه، وكم خانة فاضية قبله، وكل أيامه مع حالة كل يوم.
    private func month(startingAt firstDay: Date) -> CalendarMonth {
        // كم يوم في الشهر (28 أو 30 أو 31). لو صار خطأ، `?? 1..<1` = لا تعرض أيام.
        let dayRange = calendar.range(of: .day, in: .month, for: firstDay) ?? 1..<1
        let days = dayRange.compactMap { calendar.date(byAdding: .day, value: $0 - 1, to: firstDay) }
        return CalendarMonth(
            firstDay: firstDay,
            title: firstDay.formatted(.dateTime.month(.wide).year()),
            // `%` = باقي القسمة. يضمن إن الرقم يطلع دائماً بين 0 و 6.
            leadingBlankDays: (calendar.component(.weekday, from: firstDay) - calendar.firstWeekday + 7) % 7,
            days: days.map { DayItem(date: $0, status: store.status(on: $0), isToday: $0 == store.today) }
        )
    }
}
