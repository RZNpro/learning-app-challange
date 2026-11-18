import SwiftUI

/// شاشة البداية: تطلع أول مرة بس، أحط فيها أول هدف لي.
/// هذي الـ View (حرف الـ V في MVVM): تعرض وتنادي الـ ViewModel، وما فيها أي منطق.
///
/// `struct` + `View` = كل شاشة في SwiftUI عبارة عن struct يطبّق بروتوكول View.
struct OnboardingView: View {
    /// `@State` = الشاشة "تملك" هالـ ViewModel وتحتفظ فيه طول ما هي ظاهرة،
    /// حتى لو SwiftUI أعاد رسم الشاشة ألف مرة.
    @State private var viewModel: OnboardingViewModel

    /// أستقبل المخزن من برا وأسوي منه الـ ViewModel.
    /// `_viewModel = State(initialValue:)` = الطريقة الصحيحة أعطي فيها @State قيمة أول مرة داخل init.
    init(store: LearningStore) {
        _viewModel = State(initialValue: OnboardingViewModel(store: store))
    }

    /// `body` = وش يطلع في الشاشة.
    /// `some View` = يرجّع "نوع من الـ View"، وSwift يعرف النوع بالضبط بدون ما أكتبه.
    var body: some View {
        // `VStack` = يرتّب العناصر فوق بعض (عمودي).
        VStack(alignment: .leading, spacing: 0) {
            appIcon
                .padding(.top, 40)

            // `\(Text(...).bold())` = أدمج نص عريض داخل نص عادي.
            Text("Hello \(Text("Learner").bold())")
                .font(.system(size: 34))
                .padding(.top, 50)
            Text("This app will help you learn everyday!")
                .font(.title3)
                .foregroundStyle(.secondary)   // لون النظام الثانوي، يتغيّر لحاله بين الفاتح والغامق
                .padding(.top, 4)

            // `$viewModel.subject` = Binding: ربط بالاتجاهين.
            // لما المستخدم يكتب، تتغيّر القيمة في الـ ViewModel على طول.
            GoalForm(subject: $viewModel.subject, period: $viewModel.period)
                .padding(.top, 31)

            // `Spacer` = يعبّي المساحة الفاضية، فيدفّ الزر لتحت الشاشة.
            Spacer()

            startButton
                .padding(.bottom, 16)
        }
        .padding(.horizontal, 16)
        // لما يطلع الكيبورد لا تدفّ الزر لفوق، خلّه مكانه.
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    // قسّمت الشاشة لأجزاء (`private var`) عشان الـ body يكون قصير وواضح.

    // أيقونة النار فوق.
    private var appIcon: some View {
        Image(systemName: "flame.fill")   // SF Symbols: أيقونات Apple الجاهزة
            .font(.system(size: 36))
            .foregroundStyle(.learnOrange)
            .frame(width: 109, height: 109)
            // 🔷 Liquid Glass: `.glassEffect` يحط زجاج Apple الأصلي حول الأيقونة،
            // و `.tint` يلوّن الزجاج برتقالي خفيف، و `in: .circle` يخلي شكله دائرة.
            .glassEffect(.regular.tint(.learnOrange.opacity(0.15)), in: .circle)
            .frame(maxWidth: .infinity)   // يخليها بالنص
    }

    // زر البداية والجملة اللي تحته.
    private var startButton: some View {
        VStack(spacing: 12) {
            // `action: viewModel.startLearning` = لما أضغط، نادِ دالة الـ ViewModel.
            Button(action: viewModel.startLearning) {
                Text("Start Learning")
                    .font(.title3)
                    .foregroundStyle(viewModel.canStart ? Color.white : .secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
            }
            // 🔷 Liquid Glass: لو كتبت موضوع يصير زجاج برتقالي بارز (`.glassProminent`)،
            // ولو الخانة فاضية يصير زجاج عادي رمادي (`.glass`) وما ينضغط. نفس فكرة زر Log و Freeze.
            .glassButtonStyle(isProminent: viewModel.canStart)
            .tint(.learnOrange)
            .allowsHitTesting(viewModel.canStart)

            Text("You can edit your desire later")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// `#Preview` = أشوف الشاشة مباشرة في Xcode بدون ما أشغّل المحاكي.
#Preview {
    OnboardingView(store: .preview())
}
