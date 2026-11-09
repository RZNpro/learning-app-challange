import SwiftUI

/// 44pt round glass button holding an SF Symbol, as in the Activity header.
struct CircleIconButton: View {
    let systemName: String
    let accessibilityLabel: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.title3)
                .foregroundStyle(.primary)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: .circle)
        .accessibilityLabel(accessibilityLabel)
    }
}

#Preview {
    CircleIconButton(systemName: "calendar", accessibilityLabel: "Calendar") {}
}
