//
//  CloudFunctionsProviding.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-03-20.
//

import Foundation

/// Protocol defining Cloud Functions invocation capabilities.
///
/// Use this protocol for dependency injection to make your code testable
/// and decoupled from Firebase Cloud Functions.
///
/// This protocol provides **generic infrastructure** for calling any Cloud Function
/// with any `Codable` request and response types. Define your function-specific
/// request/response types in the **consuming app**, not in this package.
///
/// - Important: This package only provides the Swift client. The Cloud Functions
///   backend itself (TypeScript/JavaScript runtime code, `firebase.json`, deploy
///   configuration) lives in your consuming-app repo. Ship and deploy it from there
///   so the package stays generic and reusable across apps.
///
/// ## Usage in Production
///
/// ```swift
/// // Define DTOs in your app
/// struct PlacesSearchRequest: Codable, Sendable {
///     let query: String
///     let radius: Int?
/// }
///
/// struct PlacesSearchResponse: Codable, Sendable {
///     let places: [Place]
/// }
///
/// // Call the function
/// let response: PlacesSearchResponse = try await cloudFunctions.call(
///     "googlePlacesProxy",
///     data: PlacesSearchRequest(query: "coffee", radius: 500)
/// )
/// ```
///
/// ## Topics
///
/// ### Calling Functions with Data
/// - ``call(_:data:timeout:)``
///
/// ### Calling Functions without Data
/// - ``call(_:timeout:)``
///
/// ### Fire-and-forget Calls
/// - ``callVoid(_:data:timeout:)``
///
/// ### Availability
/// - ``isAvailable()``
///
/// ### Implementations
/// - ``FirebaseCloudFunctionsProvider``
public protocol CloudFunctionsProviding: Sendable {
    /// Calls a Cloud Function with a request payload and returns a decoded response.
    ///
    /// - Parameters:
    ///   - name: The name of the Cloud Function to call.
    ///   - data: The request payload conforming to `Encodable`.
    ///   - timeout: Optional timeout in seconds. Pass `nil` to use the provider default.
    /// - Returns: The decoded response from the function.
    /// - Throws: ``FirebaseError/cloudFunctionError(code:message:)`` on function errors.
    /// - Throws: ``FirebaseError/cloudFunctionTimeout`` if the call times out.
    func call<Response: Decodable & Sendable>(_ name: String,
                                              data: some Encodable & Sendable,
                                              timeout: TimeInterval?) async throws -> Response

    /// Calls a Cloud Function without a request payload and returns a decoded response.
    ///
    /// - Parameters:
    ///   - name: The name of the Cloud Function to call.
    ///   - timeout: Optional timeout in seconds. Pass `nil` to use the provider default.
    /// - Returns: The decoded response from the function.
    func call<Response: Decodable & Sendable>(_ name: String,
                                              timeout: TimeInterval?) async throws -> Response

    /// Calls a Cloud Function with a request payload, ignoring any response data.
    ///
    /// - Parameters:
    ///   - name: The name of the Cloud Function to call.
    ///   - data: The request payload conforming to `Encodable`.
    ///   - timeout: Optional timeout in seconds. Pass `nil` to use the provider default.
    func callVoid(_ name: String,
                  data: some Encodable & Sendable,
                  timeout: TimeInterval?) async throws

    /// Checks whether the Cloud Functions service is available.
    ///
    /// - Returns: `true` if the service is available and Firebase is configured.
    func isAvailable() async -> Bool
}

// MARK: - Convenience Extensions

extension CloudFunctionsProviding {
    /// Calls a Cloud Function with a request payload using the default timeout.
    public func call<Response: Decodable & Sendable>(_ name: String,
                                                     data: some Encodable & Sendable) async throws -> Response {
        try await call(name, data: data, timeout: nil)
    }

    /// Calls a Cloud Function without a request payload using the default timeout.
    public func call<Response: Decodable & Sendable>(_ name: String) async throws -> Response {
        try await call(name, timeout: nil)
    }

    /// Calls a Cloud Function with a request payload and ignores the response, using the default timeout.
    public func callVoid(_ name: String,
                         data: some Encodable & Sendable) async throws {
        try await callVoid(name, data: data, timeout: nil)
    }
}
