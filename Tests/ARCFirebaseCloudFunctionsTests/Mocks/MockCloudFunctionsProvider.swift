import Foundation
@testable import ARCFirebaseCloudFunctions

/// Mock Cloud Functions provider for testing.
final class MockCloudFunctionsProvider: CloudFunctionsProviding, @unchecked Sendable {
    // MARK: - Mock State

    var mockError: Error?
    var mockResponseData: Any?
    var mockIsAvailable = true

    private(set) var callCallCount = 0
    private(set) var callVoidCallCount = 0
    private(set) var isAvailableCallCount = 0
    private(set) var lastFunctionName: String?
    private(set) var lastTimeout: TimeInterval?

    // MARK: - CloudFunctionsProviding Implementation

    func call<Response: Decodable & Sendable>(_ name: String,
                                              data _: some Encodable & Sendable,
                                              timeout: TimeInterval?) async throws -> Response {
        callCallCount += 1
        lastFunctionName = name
        lastTimeout = timeout

        if let error = mockError {
            throw error
        }

        guard let responseData = mockResponseData else {
            throw NSError(domain: "MockError", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: "No mock response configured"])
        }

        let data = try JSONSerialization.data(withJSONObject: responseData)
        return try JSONDecoder().decode(Response.self, from: data)
    }

    func call<Response: Decodable & Sendable>(_ name: String,
                                              timeout: TimeInterval?) async throws -> Response {
        callCallCount += 1
        lastFunctionName = name
        lastTimeout = timeout

        if let error = mockError {
            throw error
        }

        guard let responseData = mockResponseData else {
            throw NSError(domain: "MockError", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: "No mock response configured"])
        }

        let data = try JSONSerialization.data(withJSONObject: responseData)
        return try JSONDecoder().decode(Response.self, from: data)
    }

    func callVoid(_ name: String,
                  data _: some Encodable & Sendable,
                  timeout: TimeInterval?) async throws {
        callVoidCallCount += 1
        lastFunctionName = name
        lastTimeout = timeout

        if let error = mockError {
            throw error
        }
    }

    func isAvailable() async -> Bool {
        isAvailableCallCount += 1
        return mockIsAvailable
    }

    // MARK: - Test Helpers

    func setMockResponse(_ response: some Encodable) throws {
        let data = try JSONEncoder().encode(response)
        mockResponseData = try JSONSerialization.jsonObject(with: data)
    }

    func reset() {
        mockError = nil
        mockResponseData = nil
        mockIsAvailable = true
        callCallCount = 0
        callVoidCallCount = 0
        isAvailableCallCount = 0
        lastFunctionName = nil
        lastTimeout = nil
    }
}
