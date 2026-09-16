import SwiftUI

struct ActionButtonLabel: View {
    let title: LocalizedStringResource
    let symbol: String
    let isLoading: Bool

    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        HStack {
            Label {
                Text(title)
                    .foregroundStyle(isEnabled ? Color.primary : Color.secondary)
            } icon: {
                Image(systemName: symbol)
            }
            if isLoading {
                Spacer()
                ProgressView()
            }
        }
    }
}
