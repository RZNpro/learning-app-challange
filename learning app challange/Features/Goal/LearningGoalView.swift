import SwiftUI

/// شاشة تعديل الهدف (Learning Goal). تنفتح من زر القلم أو من زر "Set a goal".
struct LearningGoalView: View {
    @State private var viewModel: LearningGoalViewModel
    /// `@Environment(\.dismiss)` = آخذ من النظام دالة "سكّر هالشاشة وارجع".
    /// `@Environment` يعني قيم يوفرها SwiftUI لكل الشاشات.
    @Environment(\.dismiss) private var dismiss

    init(store: LearningStore) {
        _viewModel = State(initialValue: LearningGoalViewModel(store: store))
    }

    var body: some View {
        // أعيد استخدام نفس الفورم حق الـ Onboarding.
        GoalForm(subject: $viewModel.subject, period: $viewModel.period)
            .padding(.horizontal, 16)
            .padding(.top, 24)
            .frame(maxHeight: .infinity, alignment: .top)
            // 🔷 Native: عنوان الصفحة من النظام، وزر الرجوع (<) يطلع لحاله زجاجي.
            .navigationTitle("Learning Goal")
            .inlineNavigationTitle()   // العنوان صغير بالنص، دالة سويتها في Extensions
            // `.toolbar` = أحط أزرار في شريط الأدوات فوق. النظام يعطيها شكل زجاجي تلقائياً.
            .toolbar {
                // `.confirmationAction` = مكان زر التأكيد (يمين فوق).
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", systemImage: "checkmark", action: viewModel.saveTapped)
                        .buttonStyle(.glassProminent)   // 🔷 زر زجاجي برتقالي بارز
                        .tint(.learnOrange)
                }
            }
            // 🔷 Native: `.alert` تنبيه Apple الأصلي.
            // `isPresented: $viewModel.showsUpdateAlert` = يطلع لما القيمة تصير true، ويختفي لحاله لما أضغط زر.
            .alert("Update goal", isPresented: $viewModel.showsUpdateAlert) {
                // `role: .cancel` = زر الإلغاء. ما يسوي شي، بس يسكّر التنبيه.
                Button("Dismiss", role: .cancel) {}
                Button("Update", action: viewModel.confirmUpdate)
            } message: {
                Text("If you update now, your streak will start over.")
            }
            // `.onChange` = راقب قيمة، ولما تتغيّر سوِّ شي.
            // هنا: لما الـ ViewModel يقول "خلصت الحفظ"، سكّر الشاشة.
            .onChange(of: viewModel.isFinished) { _, isFinished in
                if isFinished { dismiss() }
            }
    }
}

#Preview {
    NavigationStack {
        LearningGoalView(store: .preview(goal: .week))
    }
}
