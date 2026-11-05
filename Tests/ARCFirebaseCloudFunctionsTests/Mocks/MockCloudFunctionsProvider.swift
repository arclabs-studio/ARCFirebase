import Foundation
import os
@testable import ARCFirebaseCloudFunctions

/// Mock Cloud Functions provider for testing.
final class MockCloudFunctionsProvider: CloudFunctionsProviding {
    private struct State {
        var mockError: Error?
        var mockResponseData: Data?
        var mockIsAvailable: Bool = true
        var callCallCount: Int = 0
        var callVoidCallCount: Int = 0
        var isAvailableCallCount: Int = 0
        var lastFunctionName: String?
        var lastTimeout: TimeInterval?
    }

    private let state = OSAllocatedUnfairLock(initialState: State())

    // MARK: - Mock State

    var mockError: Error? {
        get { state.withLock { $0.mockError } }
        set { state.withLock { $0.mockError = newValue } }
    }

    var mockResponseData: Data? {
        get { state.withLock { $0.mockResponseData } }
        set { state.withLock { $0.mockResponseData = newValue } }
    }

    var mockIsAvailable: Bool {
        get { state.withLock { $0.mockIsAvailable } }
        set { state.withLock { $0.mockIsAvailable = newValue } }
    }

    var callCallCount: Int {
        state.withLock { $0.callCallCount }
    }

    var callVoidCallCount: Int {
        state.withLock { $0.callVoidCallCount }
    }

    var isAvailableCallCount: Int {
        state.withLock { $0.isAvailableCallCount }
    }

    var lastFunctionName: String? {
        state.withLock { $0.lastFunctionName }
    }

    var lastTimeout: TimeInterval? {
        state.withLock { $0.lastTimeout }
    }

    // MARK: - CloudFunctionsProviding Implementation

    func call<Response: Decodable & Sendable>(_ name: String,
                                              data _: some Encodable & Sendable,
                                              timeout: TimeInterval?) async throws -> Response {
        state.withLock { $0.callCallCount += 1 }
        state.withLock { $0.lastFunctionName = name }
        state.withLock { $0.lastTimeout = timeout }

        if let error = mockError {
            throw error
        }

        guard let responseData = mockResponseData else {
            throw NSError(domain: "MockError", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: "No mock response configured"])
        }

        return try JSONDecoder().decode(Response.self, from: responseData)
    }

    func call<Response: Decodable & Sendable>(_ name: String,
                                              timeout: TimeInterval?) async throws -> Response {
        state.withLock { $0.callCallCount += 1 }
        state.withLock { $0.lastFunctionName = name }
        state.withLock { $0.lastTimeout = timeout }

        if let error = mockError {
            throw error
        }

        guard let responseData = mockResponseData else {
            throw NSError(domain: "MockError", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: "No mock response configured"])
        }

        return try JSONDecoder().decode(Response.self, from: responseData)
    }

    func callVoid(_ name: String,
                  data _: some Encodable & Sendable,
                  timeout: TimeInterval?) async throws {
        state.withLock { $0.callVoidCallCount += 1 }
        state.withLock { $0.lastFunctionName = name }
        state.withLock { $0.lastTimeout = timeout }

        if let error = mockError {
            throw error
        }
    }

    func isAvailable() async -> Bool {
        state.withLock { $0.isAvailableCallCount += 1 }
        return mockIsAvailable
    }

    // MARK: - Test Helpers

    func setMockResponse(_ response: some Encodable) throws {
        let data = try JSONEncoder().encode(response)
        state.withLock { $0.mockResponseData = data }
    }

    func reset() {
        state.withLock { $0.mockError = nil }
        state.withLock { $0.mockResponseData = nil }
        state.withLock { $0.mockIsAvailable = true }
        state.withLock { $0.callCallCount = 0 }
        state.withLock { $0.callVoidCallCount = 0 }
        state.withLock { $0.isAvailableCallCount = 0 }
        state.withLock { $0.lastFunctionName = nil }
        state.withLock { $0.lastTimeout = nil }
    }
}
