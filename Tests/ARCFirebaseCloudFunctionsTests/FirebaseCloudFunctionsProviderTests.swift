import Testing
@testable import ARCFirebaseCloudFunctions

@Suite("FirebaseCloudFunctionsProvider Tests")
struct FirebaseCloudFunctionsProviderTests {
    // MARK: - Test Types

    struct TestRequest: Codable, Sendable {
        let query: String
    }

    struct TestResponse: Codable, Sendable, Equatable {
        let result: String
        let count: Int
    }

    // MARK: - Tests

    @Test("Mock provider calls function and returns decoded response")
    func call_withData_returnsDecodedResponse() async throws {
        let mock = makeSUT()
        let expectedResponse = TestResponse(result: "success", count: 42)
        try mock.setMockResponse(expectedResponse)

        let response: TestResponse = try await mock.call("testFunction", data: TestRequest(query: "hello"))

        #expect(response == expectedResponse)
        #expect(mock.callCallCount == 1)
        #expect(mock.lastFunctionName == "testFunction")
    }

    @Test("Mock provider tracks function name and timeout") func call_tracksNameAndTimeout() async throws {
        let mock = makeSUT()
        let expectedResponse = TestResponse(result: "ok", count: 1)
        try mock.setMockResponse(expectedResponse)

        let _: TestResponse = try await mock.call("myFunction", data: TestRequest(query: "test"), timeout: 30)

        #expect(mock.lastFunctionName == "myFunction")
        #expect(mock.lastTimeout == 30)
    }

    @Test("Mock provider throws error when configured") func call_throwsOnError() async throws {
        let mock = makeSUT()

        enum TestError: Error { case functionFailed }
        mock.mockError = TestError.functionFailed

        do {
            let _: TestResponse = try await mock.call("testFunction", data: TestRequest(query: "hello"))
            Issue.record("Expected error to be thrown")
        } catch {
            #expect(error is TestError)
            #expect(mock.callCallCount == 1)
        }
    }

    @Test("Mock provider callVoid tracks calls") func callVoid_tracksCallCount() async throws {
        let mock = makeSUT()

        try await mock.callVoid("voidFunction", data: TestRequest(query: "test"))

        #expect(mock.callVoidCallCount == 1)
        #expect(mock.lastFunctionName == "voidFunction")
    }

    @Test("Mock provider callVoid throws error when configured") func callVoid_throwsOnError() async throws {
        let mock = makeSUT()

        enum TestError: Error { case voidFailed }
        mock.mockError = TestError.voidFailed

        do {
            try await mock.callVoid("voidFunction", data: TestRequest(query: "test"))
            Issue.record("Expected error to be thrown")
        } catch {
            #expect(error is TestError)
        }
    }

    @Test("Mock provider isAvailable returns configured value") func isAvailable_returnsConfiguredValue() async {
        let mock = makeSUT()
        mock.mockIsAvailable = true

        let available = await mock.isAvailable()

        #expect(available == true)
        #expect(mock.isAvailableCallCount == 1)

        mock.mockIsAvailable = false
        let unavailable = await mock.isAvailable()
        #expect(unavailable == false)
    }

    @Test("Mock reset clears all state") func reset_clearsAllState() async throws {
        let mock = makeSUT()
        let response = TestResponse(result: "ok", count: 1)
        try mock.setMockResponse(response)

        let _: TestResponse = try await mock.call("testFunction", data: TestRequest(query: "q"))
        try await mock.callVoid("voidFunction", data: TestRequest(query: "q"))
        _ = await mock.isAvailable()

        mock.reset()

        #expect(mock.callCallCount == 0)
        #expect(mock.callVoidCallCount == 0)
        #expect(mock.isAvailableCallCount == 0)
        #expect(mock.lastFunctionName == nil)
        #expect(mock.lastTimeout == nil)
        #expect(mock.mockResponseData == nil)
        #expect(mock.mockError == nil)
    }

    // MARK: - Convenience Extension Tests

    @Test("Convenience call without timeout passes nil timeout")
    func call_withoutTimeout_passesNilTimeout() async throws {
        let mock = makeSUT()
        let response = TestResponse(result: "ok", count: 1)
        try mock.setMockResponse(response)

        let _: TestResponse = try await mock.call("testFunction", data: TestRequest(query: "q"))

        #expect(mock.lastTimeout == nil)
    }

    @Test("Convenience callVoid without timeout passes nil timeout")
    func callVoid_withoutTimeout_passesNilTimeout() async throws {
        let mock = makeSUT()

        try await mock.callVoid("testFunction", data: TestRequest(query: "q"))

        #expect(mock.lastTimeout == nil)
    }

    // MARK: - Helpers

    private func makeSUT() -> MockCloudFunctionsProvider {
        MockCloudFunctionsProvider()
    }
}
