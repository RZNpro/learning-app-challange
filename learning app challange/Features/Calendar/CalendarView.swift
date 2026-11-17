import SwiftUI

/// صفحة التقويم (Activities): فوق مجموع السنة، وتحته كل الأشهر من أول ما بديت.
struct CalendarView: View {
    @State private var viewModel: CalendarViewModel

    init(store: LearningStore) {
        _viewModel = State(initialValue: CalendarViewModel(store: store))
    }

    var body: some View {
        // `ScrollViewReader` = يخليني أنزل لمكان معيّن في الصفحة بالكود.
        // استخدمته عشان أفتح على الشهر الحالي على طول.
        ScrollViewReader { proxy in
            ScrollView {
                // `LazyVStack` = مثل VStack، بس يرسم بس اللي ظاهر في الشاشة.
                // هذا أخف بكثير لو عندي أشهر كثيرة.
                LazyVStack(alignment: .leading, spacing: 0) {
                    yearSummary
                        .padding(.horizontal, 4)
                        .padding(.bottom, 8)

                    ForEach(viewModel.months) { month in
                        MonthGrid(month: month, weekdaySymbols: viewModel.weekdaySymbols)
                            .id(month.id)   // أعطي كل شهر id عشان أقدر أنزل له بالـ proxy
                        Divider()
                    }
                }
                .padding(.horizontal, 12)
            }
            // `.onAppear` = يشتغل أول ما تظهر الصفحة.
            .onAppear {
                proxy.scrollTo(viewModel.currentMonthID, anchor: .top)
            }
        }
        // 🔷 Native: عنوان الصفحة من النظام، وزر الرجوع زجاجي تلقائياً.
        .navigationTitle("Activities")
        .inlineNavigationTitle()
    }

    /// مجموع أيام التعلم والتجميد في السنة كلها.
    /// أضفته لأن العدادات في Activity تتصفّر مع كل هدف، فهنا أشوف إنجازي الكامل.
    private var yearSummary: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("This year")
                .font(.title3.weight(.semibold))
                .padding(.horizontal, 4)
            HStack(spacing: 12) {
                // نفس البطاقات حقت Activity. أعدت استخدامها بدل ما أكررها.
                StatCard.learned(viewModel.learnedThisYear)
                StatCard.freezed(viewModel.freezedThisYear)
            }
        }
        .padding(.top, 16)
    }
}

/// شهر واحد مرسوم كشبكة من 7 أعمدة (أيام الأسبوع).
/// هذا الجزء الوحيد اللي رسمته يدوي (Custom)، لأن SwiftUI ما فيه تقويم جاهز يلوّن الأيام بألوان مختلفة.
private struct MonthGrid: View {
    let month: CalendarMonth
    let weekdaySymbols: [String]

    // 7 أعمدة بعرض متساوي. `Array(repeating:count:)` = كرّر نفس العنصر 7 مرات.
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(month.title)
                .font(.title3.weight(.semibold))
                .padding(.horizontal, 8)

            // `LazyVGrid` = شبكة عمودية. العناصر تتوزع على الأعمدة وتنزل سطر سطر.
            LazyVGrid(columns: columns, spacing: 6) {
                // أول سطر: أسماء الأيام. `id: \.self` لأن النص نفسه مميز وما يتكرر.
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                // خانات فاضية قبل يوم 1، عشان يجي تحت اسم اليوم الصح.
                ForEach(0..<month.leadingBlankDays, id: \.self) { _ in
                    Color.clear.frame(height: 44)
                }
                // أيام الشهر نفسها.
                ForEach(month.days) { day in
                    DayCircle(day: day)
                }
            }
        }
        .padding(.vertical, 16)
    }
}

#Preview {
    NavigationStack {
        CalendarView(store: .preview(goal: .week))
    }
}
