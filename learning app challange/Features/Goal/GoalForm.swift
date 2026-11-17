import SwiftUI

/// خانة "I want to learn" + اختيار المدة.
/// سويتها View لحالها لأني أستخدمها في شاشتين: الـ Onboarding وتعديل الهدف.
/// كذا ما أكرر نفس الكود مرتين (مبدأ DRY: Don't Repeat Yourself).
struct GoalForm: View {
    /// `@Binding` = هالـ View ما تملك البيانات، بس "تستلفها" من الشاشة الأم.
    /// أي تعديل هنا يتغيّر عند الأم على طول، والعكس. الأم تمررها بعلامة `$`.
    ///
    /// 💡 الفرق: `@State` = أنا أملك البيانات. `@Binding` = أستخدم بيانات غيري وأعدّلها.
    @Binding var subject: String
    @Binding var period: GoalPeriod

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("I want to learn")
                .font(.title3)
            // `TextField` = خانة كتابة. "Swift" نص رمادي يطلع لما تكون فاضية (Placeholder).
            TextField("Swift", text: $subject)
                .font(.title3)
                .autocorrectionDisabled()   // أطفي التصحيح التلقائي
                .padding(.top, 16)
                .padding(.bottom, 12)
            Divider()   // الخط الرفيع تحت الخانة

            Text("I want to learn it in a")
                .font(.title3)
                .padding(.top, 24)
                .padding(.bottom, 12)
            // 🔷 Native: `Picker` عنصر Apple الأصلي للاختيار.
            // `ForEach(GoalPeriod.allCases)` يسوي خيار لكل case في الـ enum (هنا فايدة CaseIterable).
            // `.tag(period)` يربط كل خيار بقيمته.
            Picker("Duration", selection: $period) {
                ForEach(GoalPeriod.allCases) { period in
                    Text(period.title).tag(period)
                }
            }
            // `.segmented` = الشكل اللي الخيارات فيه جنب بعض في شريط واحد.
            // في iOS 26 وما بعده يطلع زجاجي لحاله، بدون ما أسوي شي.
            .pickerStyle(.segmented)
        }
    }
}

// `.constant(...)` = Binding ثابت للمعاينة بس، لأن الـ Preview ما عنده شاشة أم.
#Preview {
    GoalForm(subject: .constant(""), period: .constant(.week))
        .padding()
}
