//
//  FirebaseCloudFunctionsProvider.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-03-20.
//

import ARCFirebaseCore
import ARCLogger
import FirebaseFunctions
import Foundation

/// Firebase implementation of ``CloudFunctionsProviding``.
///
/// This is the production Cloud Functions provider that calls Firebase Functions.
/// Firebase SDK automatically attaches App Check tokens to all calls when App Check
/// is configured, without any additional code required in this provider.
///
/// ## Initialization
///
/// ```swift
/// // Create with default configuration
/// let functions = try FirebaseCloudFunctionsProvider()
///
/// // Or use the convenience default
/// let functions = FirebaseCloudFunctionsProvider.live
/// ```
///
/// ## SwiftUI Integration
///
/// ```swift
/// @main
/// struct MyApp: App {
///     let functions = FirebaseCloudFunctionsProvider.live
///
///     var body: some Scene {
///         WindowGroup {
///             ContentView()
///                 .environment(\.cloudFunctionsProvider, functions)
///         }
///     }
/// }
/// ```
///
/// ## Topics
///
/// ### Initialization
/// - ``init(configuration:)``
/// - ``live``
/// - ``create(configuration:)``
///
/// ### CloudFunctionsProviding Implementation
/// - ``call(_:data:timeout:)``
/// - ``call(_:timeout:)``
/// - ``callVoid(_:data:timeout:)``
/// - ``isAvailable()``
public final class FirebaseCloudFunctionsProvider: CloudFunctionsProviding, @unchecked Sendable {
    // MARK: - Properties

    private let functions: Functions
    private let configuration: CloudFunctionsConfiguration
    private let logger = ARCLogger(subsystem: ARCFirebaseLogSubsystem.current, category: "CloudFunctions")

    // MARK: - Initialization

    /// Creates a Cloud Functions provider with the given configuration.
    ///
    /// - Parameter configuration: The Cloud Functions configuration. Defaults to
    /// ``CloudFunctionsConfiguration/default``.
    /// - Throws: ``FirebaseError/notConfigured`` if Firebase hasn't been initialized.
    public init(configuration: CloudFunctionsConfiguration = .default) throws {
        try FirebaseManager.ensureConfigured()
        self.configuration = configuration
        functions = Functions.functions(region: configuration.region)
        logger.info("FirebaseCloudFunctionsProvider initialized for region: \(configuration.region)")
    }

    // MARK: - CloudFunctionsProviding Implementation

    public func call<Response: Decodable & Sendable>(_ name: String,
                                                     data: some Encodable & Sendable,
                                                     timeout: TimeInterval?) async throws -> Response {
        logger.info("Calling function: \(name)")

        let callable = functions.httpsCallable(name)
        callable.timeoutInterval = timeout ?? configuration.defaultTimeout

        do {
            let result = try await callable.call(data)
            let response: Response = try decodeResponse(result.data)
            logger.info("Function call succeeded: \(name)")
            return response
        } catch let error as FirebaseError {
            throw error
        } catch {
            logger.error("Function call failed: \(name) — \(error.localizedDescription)")
            throw error.asFirebaseError()
        }
    }

    public func call<Response: Decodable & Sendable>(_ name: String,
                                                     timeout: TimeInterval?) async throws -> Response {
        logger.info("Calling function (no data): \(name)")

        let callable = functions.httpsCallable(name)
        callable.timeoutInterval = timeout ?? configuration.defaultTimeout

        do {
            let result = try await callable.call()
            let response: Response = try decodeResponse(result.data)
            logger.info("Function call succeeded: \(name)")
            return response
        } catch let error as FirebaseError {
            throw error
        } catch {
            logger.error("Function call failed: \(name) — \(error.localizedDescription)")
            throw error.asFirebaseError()
        }
    }

    public func callVoid(_ name: String,
                         data: some Encodable & Sendable,
                         timeout: TimeInterval?) async throws {
        logger.info("Calling function (void): \(name)")

        let callable = functions.httpsCallable(name)
        callable.timeoutInterval = timeout ?? configuration.defaultTimeout

        do {
            _ = try await callable.call(data)
            logger.info("Function call (void) succeeded: \(name)")
        } catch let error as FirebaseError {
            throw error
        } catch {
            logger.error("Function call (void) failed: \(name) — \(error.localizedDescription)")
            throw error.asFirebaseError()
        }
    }

    public func isAvailable() async -> Bool {
        (try? FirebaseManager.ensureConfigured()) != nil
    }

    // MARK: - Private Helpers

    private func decodeResponse<T: Decodable>(_ responseData: Any) throws -> T {
        guard JSONSerialization.isValidJSONObject(responseData) else {
            throw FirebaseError.cloudFunctionError(code: "decode-error",
                                                   message: "Unexpected response format from Cloud Function")
        }
        let data = try JSONSerialization.data(withJSONObject: responseData)
        return try JSONDecoder().decode(T.self, from: data)
    }
}

// MARK: - Factory Methods

extension FirebaseCloudFunctionsProvider {
    /// Creates a new Cloud Functions provider with the given configuration.
    ///
    /// - Parameter configuration: The Cloud Functions configuration.
    /// - Returns: A configured ``FirebaseCloudFunctionsProvider`` instance.
    /// - Throws: ``FirebaseError/notConfigured`` if Firebase hasn't been initialized.
    public static func create(configuration: CloudFunctionsConfiguration = .default) throws
    -> FirebaseCloudFunctionsProvider {
        try FirebaseCloudFunctionsProvider(configuration: configuration)
    }

    /// Default live instance for production use.
    ///
    /// - Important: This will crash if Firebase is not configured.
    ///              Call ``FirebaseManager/configure()`` first.
    public static var live: FirebaseCloudFunctionsProvider {
        do {
            return try create()
        } catch {
            fatalError("""
            FirebaseCloudFunctionsProvider initialization failed.
            Ensure FirebaseManager.shared.configure() is called before accessing .live.
            Error: \(error.localizedDescription)
            """)
        }
    }
}
