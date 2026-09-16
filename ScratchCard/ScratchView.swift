import SwiftUI

struct ScratchView: View {
    let store: ScratchCardStore
    @State private var scratchTask: Task<Void, Never>?

    var body: some View {
        List {
            CardStateSection(state: store.state)
            Section {
                Button {
                    scratchTask = Task { await store.scratch() }
                } label: {
                    ActionButtonLabel(
                        title: .scratchAction,
                        symbol: Constants.Symbol.scratchAction,
                        isLoading: store.isScratching
                    )
                }
                .disabled(store.state != .unscratched || store.isScratching)
            }
        }
        .navigationTitle(Text(.scratchScreenTitle))
        .onDisappear {
            print(Constants.Log.scratchScreenClosed)
            scratchTask?.cancel()
        }
    }
}
