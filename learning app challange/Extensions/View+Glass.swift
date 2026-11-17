import SwiftUI

extension View {
    /// Apple's native Liquid Glass button styles: tinted `.glassProminent` while the
    /// button is active, regular `.glass` once it is done or unavailable.
    /// Used instead of `.disabled`, which flattens the glass into a grey shape.
    @ViewBuilder
    func glassButtonStyle(isProminent: Bool) -> some View {
        if isProminent {
            buttonStyle(.glassProminent)
        } else {
            buttonStyle(.glass)
        }
    }
}
