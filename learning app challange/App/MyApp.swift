import SwiftUI

@main struct MyApp: App {
    @State private var store = LearningStore()

    var body: some Scene {
        WindowGroup {
            RootView(store: store)
                #if DEBUG
                .onAppear { SampleHistory.seedIfNeeded(store) }
                #endif
        }
    }
}
