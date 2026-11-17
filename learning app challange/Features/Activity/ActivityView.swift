import SwiftUI

/// الشاشة الرئيسية (Activity): أشوف فيها أسبوعي وعداداتي وأسجّل يومي.
struct ActivityView: View {
    @State private var viewModel: ActivityViewModel
    // أحتفظ بالمخزن عشان أمرره للصفحات اللي أفتحها (التقويم وتعديل الهدف).
    private let store: LearningStore

    init(store: LearningStore) {
        self.store = store
        _viewModel = State(initialValue: ActivityViewModel(store: store))
    }

    var body: some View {
        // `NavigationStack` = يسمح لي أنتقل لصفحات ثانية وأرجع.
        // `path:` مربوط بالـ ViewModel، فلما أضيف صفحة للمسار تنفتح لحالها.
        NavigationStack(path: $viewModel.path) {
            VStack(spacing: 0) {
                // `if let` = لو فيه جملة هدف (مو nil)، اعرضها. ولو لا، لا تعرض شي.
                if let goalText = viewModel.goalText {
                    Label(goalText, systemImage: "target")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.learnOrange)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                WeekStrip(viewModel: viewModel)
                    .padding(.top, 16)

                // `HStack` = يرتّب العناصر جنب بعض (أفقي).
                HStack(spacing: 12) {
                    StatCard.learned(viewModel.learnedCount)
                    StatCard.freezed(viewModel.freezedCount)
                }
                .padding(.top, 12)

                // لو الهدف خلص، أعرض النتيجة. ولو لا، أعرض أزرار التسجيل.
                if let ended = viewModel.goalEndedContent {
                    GoalEndedView(content: ended, setGoal: viewModel.showGoalEditor)
                } else {
                    LogTodaySection(viewModel: viewModel)
                }
            }
            .padding(.horizontal, 16)
            // 🔷 Native: العنوان الكبير "Activity" والتاريخ تحته من النظام، مو نصوص رسمتها بيدي.
            .navigationTitle("Activity")
            .navigationSubtitle(viewModel.dateText)
            // 🔷 Native + Liquid Glass: أزرار التقويم والقلم في شريط الأدوات.
            // النظام يعطيها الشكل الزجاجي الدائري تلقائياً.
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Calendar", systemImage: "calendar", action: viewModel.showCalendar)
                }
                // `ToolbarSpacer` = مسافة بين الزرين، عشان كل واحد يطلع في دائرة زجاج لحاله بدل ما يلتصقون.
                ToolbarSpacer(.fixed, placement: .primaryAction)
                ToolbarItem(placement: .primaryAction) {
                    Button("Edit goal", systemImage: "pencil.and.outline", action: viewModel.showGoalEditor)
                }
            }
            // هنا أحدد كل route وش يفتح.
            // `switch` على الـ enum، ولازم أغطي كل الحالات.
            .navigationDestination(for: ActivityRoute.self) { route in
                switch route {
                case .calendar: CalendarView(store: store)
                case .editGoal: LearningGoalView(store: store)
                }
            }
        }
    }
}

/// شريط الأسبوع: 7 دوائر، كل وحدة ملوّنة حسب حالة اليوم.
/// `private struct` = View صغيرة تخص هالملف بس. قسّمت الشاشة لقطع عشان تكون أوضح.
private struct WeekStrip: View {
    let viewModel: ActivityViewModel

    var body: some View {
        HStack(spacing: 0) {
            // `ForEach` = كرّر لكل يوم. يشتغل لأن `DayItem` عنده `id` (Identifiable).
            ForEach(viewModel.weekDays) { day in
                VStack(spacing: 6) {
                    Text(viewModel.weekdayLetter(for: day.date))
                        .font(.subheadline.weight(.semibold))
                    DayCircle(day: day)
                }
                .frame(maxWidth: .infinity)   // كل يوم ياخذ نفس العرض
            }
        }
    }
}

/// الدائرة الكبيرة "Log as Learned" + زر "Freeze for a day".
private struct LogTodaySection: View {
    let viewModel: ActivityViewModel

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            logButton
            Spacer()
            freezeButton
            Text(viewModel.freezesUsedText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.top, 14)
                .padding(.bottom, 24)
        }
    }

    private var logButton: some View {
        Button {
            // `withAnimation` = التغيير اللي يصير بعد الضغط يكون بحركة ناعمة، مو مفاجئ.
            withAnimation(.snappy) { viewModel.logLearned() }
        } label: {
            Text(viewModel.logButtonTitle)
                .font(.title3.bold())
                // `? :` = Ternary: if قصيرة. لو أقدر أسجّل أبيض، ولو لا رمادي.
                .foregroundStyle(viewModel.canLogLearned ? Color.white : .secondary)
                .frame(width: 250, height: 250)
        }
        // 🔷 Liquid Glass: زجاج برتقالي بارز قبل التسجيل، وزجاج عادي رمادي بعده.
        // `glassButtonStyle` دالة سويتها في Extensions/View+Glass.
        .glassButtonStyle(isProminent: viewModel.canLogLearned)
        .buttonBorderShape(.circle)   // شكل الزر دائرة
        .tint(.learnOrange)
        // ما استخدمت `.disabled` لأنه يخلي الزجاج رمادي مسطح. بدلها أوقف اللمس بس.
        .allowsHitTesting(viewModel.canLogLearned)
    }

    private var freezeButton: some View {
        Button {
            withAnimation(.snappy) { viewModel.freeze() }
        } label: {
            Text(viewModel.freezeButtonTitle)
                .font(.title3)
                .foregroundStyle(viewModel.canFreeze ? Color.white : .secondary)
                .frame(width: 240)
                .padding(.vertical, 8)
        }
        // 🔷 Liquid Glass: نفس فكرة زر Log، بس سماوي وشكله كبسولة.
        .glassButtonStyle(isProminent: viewModel.canFreeze)
        .buttonBorderShape(.capsule)
        .tint(.freezeCyan)
        .allowsHitTesting(viewModel.canFreeze)
    }
}

/// يطلع لما تخلص مدة الهدف: إما "Well done!" أو "You didn't reach your goal".
private struct GoalEndedView: View {
    let content: GoalEndedContent
    // `() -> Void` = Closure: دالة أمررها كمتغيّر. هنا "وش يصير لما أضغط Set a goal".
    let setGoal: () -> Void

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: content.icon)
                .font(.system(size: 40))
                .foregroundStyle(.learnOrange)
                .padding(.bottom, 12)
            Text(content.title)
                .font(.headline)
                .multilineTextAlignment(.center)
            Text(content.subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button(action: setGoal) {
                Label("Set a goal", systemImage: "pencil.and.outline")
                    .font(.title3)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.glassProminent)   // 🔷 زر زجاجي برتقالي
            .tint(.learnOrange)
            .padding(.top, 70)
        }
        .padding(.top, 70)
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    ActivityView(store: .preview(goal: .week))
}
