import SwiftUI

// مجلد Components = عناصر صغيرة أستخدمها في أكثر من شاشة.

/// بيانات يوم واحد جاهزة للعرض. يجهّزها الـ ViewModel، والـ View بس تعرضها.
///
/// `Identifiable` = له `id` عشان `ForEach` يعرف كل يوم.
/// `Hashable` = يقدر Swift يميّز كل يوم ويقارنه بغيره.
struct DayItem: Identifiable, Hashable {
    let date: Date
    // `DayStatus?` Optional: إذا nil يعني اليوم ما انسجل فيه شي.
    let status: DayStatus?
    let isToday: Bool

    var id: Date { date }   // التاريخ نفسه مميز، فاستخدمته كـ id
}

/// دائرة رقم اليوم، لونها حسب حالته:
/// برتقالي = تعلمت، سماوي = جمّدت، دائرة برتقالية ممتلئة = اليوم ولسا ما سجلت، بدون لون = عادي.
/// أستخدمها في شريط الأسبوع والتقويم.
struct DayCircle: View {
    let day: DayItem

    var body: some View {
        Text(day.date, format: .dateTime.day())   // يطلع رقم اليوم بس (مثلاً 17)
            .font(.title2.weight(isHighlightedToday ? .bold : .medium))
            .foregroundStyle(foreground)
            .frame(width: 44, height: 44)   // 44 = أقل حجم تنصح فيه Apple عشان يكون سهل اللمس
            .background(background, in: .circle)
    }

    // اليوم الحالي ولسا ما سجلته؟ هذا اللي ياخذ الدائرة البرتقالية الممتلئة.
    private var isHighlightedToday: Bool { day.isToday && day.status == nil }

    // لون الرقم. `switch` على Optional: أقدر أكتب `case nil` للحالة اللي ما فيها قيمة.
    private var foreground: Color {
        switch day.status {
        case .learned: .learnOrange
        case .freezed: .freezeCyan
        case nil: isHighlightedToday ? .white : .primary   // `.primary` = أسود بالفاتح وأبيض بالغامق
        }
    }

    // لون خلفية الدائرة. `.opacity` = شفافية، يخلي اللون فاتح.
    private var background: Color {
        switch day.status {
        case .learned: .learnOrange.opacity(0.18)
        case .freezed: .freezeCyan.opacity(0.15)
        case nil: isHighlightedToday ? .learnOrange : .clear
        }
    }
}

#Preview {
    HStack {
        DayCircle(day: DayItem(date: .now, status: .learned, isToday: false))
        DayCircle(day: DayItem(date: .now, status: .freezed, isToday: false))
        DayCircle(day: DayItem(date: .now, status: nil, isToday: true))
        DayCircle(day: DayItem(date: .now, status: nil, isToday: false))
    }
}
