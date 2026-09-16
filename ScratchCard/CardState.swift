import SwiftUI

enum CardState: Equatable {
    case unscratched
    case scratched(code: String)
    case activated(code: String)

    var title: LocalizedStringResource {
        switch self {
        case .unscratched: .stateUnscratched
        case .scratched: .stateScratched
        case .activated: .stateActivated
        }
    }

    var symbol: String {
        switch self {
        case .unscratched: Constants.Symbol.unscratched
        case .scratched: Constants.Symbol.scratched
        case .activated: Constants.Symbol.activated
        }
    }

    var color: Color {
        switch self {
        case .unscratched: .unscratchedState
        case .scratched: .scratchedState
        case .activated: .activatedState
        }
    }

    var code: String? {
        switch self {
        case .unscratched: nil
        case let .scratched(code), let .activated(code): code
        }
    }
}
