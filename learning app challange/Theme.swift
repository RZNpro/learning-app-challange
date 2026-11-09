import SwiftUI

/// Colors taken from the "Learning Journey 2026" Sketch file.
extension Color {
    static let learnOrange = Color(red: 1.0, green: 0.573, blue: 0.188)      // #FF9230
    static let freezeCyan = Color(red: 0.235, green: 0.827, blue: 0.996)     // #3CD3FE
    static let secondaryLabel = Color(red: 0.557, green: 0.557, blue: 0.576) // #8E8E93
    static let cardBackground = Color(white: 0.06)
    static let mutedFill = Color(white: 0.11)
}

extension View {
    /// Inline navigation title on iOS; no-op on platforms without that display mode.
    func inlineNavigationTitle() -> some View {
        #if os(iOS)
        navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }

    /// Hides the navigation bar on iOS so a screen can draw its own header.
    func hiddenNavigationBar() -> some View {
        #if os(iOS)
        toolbar(.hidden, for: .navigationBar)
        #else
        self
        #endif
    }
}

/// Pill used for the Week / Month / Year choice in onboarding and goal editing.
struct PeriodPicker: View {
    @Binding var selection: GoalPeriod

    var body: some View {
        HStack(spacing: 12) {
            ForEach(GoalPeriod.allCases) { period in
                let isSelected = period == selection
                Button {
                    selection = period
                } label: {
                    Text(period.title)
                        .font(.body)
                        .foregroundStyle(isSelected ? .white : .secondaryLabel)
                        .frame(minWidth: 60)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.glassProminent)
                .tint(isSelected ? .learnOrange : .mutedFill)
            }
        }
    }
}

/// "I want to learn" text field + period picker, shared by onboarding and the goal editor.
struct GoalForm: View {
    @Binding var subject: String
    @Binding var period: GoalPeriod

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("I want to learn")
                .font(.title3)
            TextField("Swift", text: $subject)
                .font(.title3)
                .padding(.top, 16)
                .padding(.bottom, 12)
                .autocorrectionDisabled()
            Divider()
            Text("I want to learn it in a")
                .font(.title3)
                .padding(.top, 24)
                .padding(.bottom, 12)
            PeriodPicker(selection: $period)
        }
    }
}
