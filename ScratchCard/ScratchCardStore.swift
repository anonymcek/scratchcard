import Foundation
import Observation

enum ActivationError: LocalizedError, Equatable {
    case unsupportedVersion(String)

    var errorDescription: String? {
        switch self {
        case let .unsupportedVersion(version):
            String(localized: .unsupportedVersionError(version))
        }
    }
}

@MainActor
@Observable
final class ScratchCardStore {
    private(set) var state: CardState
    private(set) var isScratching = false
    private(set) var isActivating = false
    var errorMessage: String?

    /// custom service provider to achieve testability
    private let service: any VersionService
    private let scratchDuration: Duration

    init(
        state: CardState = .unscratched,
        service: any VersionService = APIVersionService(),
        scratchDuration: Duration = Constants.Card.scratchDuration
    ) {
        self.state = state
        self.service = service
        self.scratchDuration = scratchDuration
    }

    func scratch() async {
        guard state == .unscratched, !isScratching else { return }

        isScratching = true
        defer { isScratching = false }

        print(Constants.Log.scratchStarted)
        do {
            // simulates long running task
            try await Task.sleep(for: scratchDuration)
            try Task.checkCancellation()
            state = .scratched(code: UUID().uuidString)
            print(Constants.Log.scratchFinished)
        } catch {
            print(Constants.Log.scratchCancelled)
        }
    }

    @discardableResult
    func activate() -> Task<Void, Never>? {
        guard case let .scratched(code) = state, !isActivating else { return nil }

        isActivating = true
        print(Constants.Log.activationStarted)

        return Task {
            defer { isActivating = false }

            do {
                let version = try await service.iosVersion(code: code)
                let minimumVersion = Constants.Card.minimumActivationVersion
                let comparison = version.compare(minimumVersion, options: .numeric)
                guard comparison == .orderedDescending else {
                    throw ActivationError.unsupportedVersion(version)
                }

                state = .activated(code: code)
                print(Constants.Log.activationFinished)
            } catch {
                print(Constants.Log.activationFailed(error.localizedDescription))
                errorMessage = error.localizedDescription
            }
        }
    }
}
