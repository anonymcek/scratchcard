import SwiftUI

struct MainView: View {
    let store: ScratchCardStore

    var body: some View {
        NavigationStack {
            List {
                CardStateSection(state: store.state)
                Section {
                    NavigationLink {
                        ScratchView(store: store)
                    } label: {
                        Label {
                            Text(.scratchAction)
                        } icon: {
                            Image(systemName: Constants.Symbol.scratchAction)
                        }
                    }
                    NavigationLink {
                        ActivationView(store: store)
                    } label: {
                        Label {
                            Text(.activateAction)
                        } icon: {
                            Image(systemName: Constants.Symbol.activateAction)
                        }
                    }
                }
            }
            .navigationTitle(Text(.mainScreenTitle))
        }
    }
}

struct CardStateSection: View {
    let state: CardState

    var body: some View {
        Section {
            Label { Text(state.title) } icon: { Image(systemName: state.symbol) }
                .font(.headline)
                .foregroundStyle(state.color)
            if let code = state.code {
                Text(verbatim: code).font(.footnote.monospaced())
            }
        } header: {
            Text(.stateSectionTitle)
        }
    }
}

#Preview {
    MainView(store: ScratchCardStore())
}
