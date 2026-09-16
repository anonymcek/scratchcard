import SwiftUI

@main
struct ScratchCardApp: App {
    @State private var store = ScratchCardStore()

    var body: some Scene {
        WindowGroup {
            MainView(store: store)
        }
    }
}
