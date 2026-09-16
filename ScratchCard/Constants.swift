import Foundation

enum Constants {
    enum Symbol {
        static let unscratched = "rectangle.dashed"
        static let scratched = "eye"
        static let activated = "checkmark.seal.fill"
        static let scratchAction = "hand.draw"
        static let activateAction = "checkmark.seal"
    }

    enum API {
        static let versionURL = "https://api.o2.sk/version"
        static let codeParameter = "code"
        static let versionMethod = "GET"
    }

    enum Card {
        static let scratchDuration: Duration = .seconds(2)
        static let minimumActivationVersion = "6.1"
    }

    enum Log {
        static let scratchStarted = "Scratch started"
        static let scratchFinished = "Scratch finished"
        static let scratchCancelled = "Scratch cancelled"
        static let scratchScreenClosed = "Scratch screen closed"
        static let activationStarted = "Activation started"
        static let activationFinished = "Activation finished"
        static let activationScreenClosed = "Activation screen closed"

        static func activationFailed(_ reason: String) -> String {
            "Activation failed: \(reason)"
        }
    }
}
