import SwiftUI

/// iOS-only modifiers wrapped so the multiplatform target still compiles elsewhere.
extension View {
    /// Inline navigation title on iOS.
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
