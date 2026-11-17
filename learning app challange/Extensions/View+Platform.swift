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
}
