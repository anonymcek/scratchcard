import SwiftUI

struct ActivationView: View {
    let store: ScratchCardStore

    var body: some View {
        List {
            CardStateSection(state: store.state)
            Section {
                Button {
                    store.activate()
                } label: {
                    ActionButtonLabel(
                        title: .activateAction,
                        symbol: Constants.Symbol.activateAction,
                        isLoading: store.isActivating
                    )
                }
                .disabled(!canActivate)
            }
        }
        .navigationTitle(Text(.activationScreenTitle))
        .onDisappear { print(Constants.Log.activationScreenClosed) }
        .alert(Text(.activationFailedTitle), isPresented: isShowingError) {
            Button(role: .cancel) {} label: { Text(.okAction) }
        } message: {
            Text(verbatim: store.errorMessage ?? "")
        }
    }

    private var canActivate: Bool {
        if case .scratched = store.state { !store.isActivating } else { false }
    }

    private var isShowingError: Binding<Bool> {
        Binding(
            get: { store.errorMessage != nil },
            set: { isPresented in
                if !isPresented { store.errorMessage = nil }
            }
        )
    }
}
