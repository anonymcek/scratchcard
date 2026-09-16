import Foundation
import Testing
@testable import ScratchCard

private struct StubVersionService: VersionService {
    let respond: @Sendable (String) async throws -> String

    func iosVersion(code: String) async throws -> String {
        try await respond(code)
    }
}

@MainActor
struct ScratchCardStoreTests {
    @Test func scratchRevealsUUIDCode() async throws {
        let store = ScratchCardStore(scratchDuration: .zero)

        await store.scratch()

        guard case let .scratched(code) = store.state else {
            Issue.record("expected scratched, got \(store.state)")
            return
        }
        #expect(UUID(uuidString: code) != nil)
        #expect(!store.isScratching)
    }

    @Test func cancelledScratchLeavesCardUnscratched() async {
        let store = ScratchCardStore(scratchDuration: .seconds(60))

        let scratchTask = Task { await store.scratch() }
        while !store.isScratching { await Task.yield() }
        scratchTask.cancel()
        await scratchTask.value

        #expect(store.state == .unscratched)
        #expect(!store.isScratching)
    }

    @Test func scratchedCardIsNotScratchedAgain() async {
        let store = ScratchCardStore(state: .scratched(code: "A"), scratchDuration: .zero)

        await store.scratch()

        #expect(store.state == .scratched(code: "A"))
    }

    @Test(arguments: ["6.2", "6.10", "6.24", "7.0"])
    func activatesWhenVersionIsGreaterThanMinimum(version: String) async {
        let store = ScratchCardStore(
            state: .scratched(code: "A"),
            service: StubVersionService { code in
                #expect(code == "A")
                return version
            }
        )

        await store.activate()?.value

        #expect(store.state == .activated(code: "A"))
        #expect(store.errorMessage == nil)
        #expect(!store.isActivating)
    }

    @Test(arguments: [Constants.Card.minimumActivationVersion, "6.0", "5.9"])
    func showsErrorWhenVersionIsNotGreaterThanMinimum(version: String) async {
        let store = ScratchCardStore(
            state: .scratched(code: "A"),
            service: StubVersionService { _ in version }
        )

        await store.activate()?.value

        #expect(store.state == .scratched(code: "A"))
        let expectedMessage = ActivationError.unsupportedVersion(version).localizedDescription
        #expect(store.errorMessage == expectedMessage)
        #expect(expectedMessage.contains(version))
    }

    @Test func showsErrorWhenRequestFails() async {
        let store = ScratchCardStore(
            state: .scratched(code: "A"),
            service: StubVersionService { _ in throw URLError(.notConnectedToInternet) }
        )

        await store.activate()?.value

        #expect(store.state == .scratched(code: "A"))
        #expect(store.errorMessage != nil)
    }

    @Test func unscratchedCardCannotBeActivated() {
        let store = ScratchCardStore(service: StubVersionService { _ in "6.24" })

        #expect(store.activate() == nil)
        #expect(store.state == .unscratched)
    }

    @Test func activationIsNotStartedTwice() async {
        let store = ScratchCardStore(
            state: .scratched(code: "A"),
            service: StubVersionService { _ in "6.24" }
        )

        let firstActivation = store.activate()
        #expect(store.activate() == nil)
        await firstActivation?.value
    }

    @Test func requestTargetsVersionEndpoint() throws {
        let code = "ABC-123"
        let request = try APIVersionService.request(code: code)
        let expectedURL = "\(Constants.API.versionURL)?\(Constants.API.codeParameter)=\(code)"

        #expect(request.httpMethod == Constants.API.versionMethod)
        #expect(request.url?.absoluteString == expectedURL)
    }
}
