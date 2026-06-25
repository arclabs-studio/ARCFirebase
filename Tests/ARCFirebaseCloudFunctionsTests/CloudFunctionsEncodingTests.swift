import Foundation
import Testing
@testable import ARCFirebaseCloudFunctions

/// Minimal JSON value tree, mirroring the app's `AnyJSON` wrapper used to
/// round-trip the heterogeneous schema dictionary through `Codable`.
private enum JSONValue: Encodable {
    case string(String)
    case bool(Bool)
    case int(Int)
    case array([JSONValue])
    case object([String: JSONValue])

    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .string(value): try container.encode(value)
        case let .bool(value): try container.encode(value)
        case let .int(value): try container.encode(value)
        case let .array(value): try container.encode(value)
        case let .object(value): try container.encode(value)
        }
    }
}

/// Mirrors the shape of the app's `AIProxyRequest`: primitive fields plus a
/// heterogeneous schema dictionary. This is the exact payload shape the legacy
/// `FunctionsSerializer` rejected with `unsupportedType("AIProxyRequest")`.
private struct ProxyRequestFixture: Encodable {
    let prompt: String
    let maxTokens: Int
    let temperature: Double

    private enum CodingKeys: String, CodingKey {
        case prompt
        case maxTokens
        case temperature
        case responseSchema = "response_schema"
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(prompt, forKey: .prompt)
        try container.encode(maxTokens, forKey: .maxTokens)
        try container.encode(temperature, forKey: .temperature)
        let schema: JSONValue = .object(["type": .string("object"),
                                         "nullable": .bool(false),
                                         "maxItems": .int(5),
                                         "fields": .array([.string("name"), .string("rating")])])
        try container.encode(schema, forKey: .responseSchema)
    }
}

/// Regression coverage for FVRS-288: the legacy `HTTPSCallable.call(_ data: Any?)`
/// runs `FunctionsSerializer`, which rejects arbitrary `Codable` structs with
/// `unsupportedType(typeName: "AIProxyRequest")`. The provider now bridges
/// `Encodable` → a JSON object graph the serializer accepts before calling.
struct CloudFunctionsEncodingTests {
    @Test("Struct payload encodes to a FunctionsSerializer-acceptable JSON object")
    func encodeToJSONObject_structWithSchema_producesValidJSONObject() throws {
        // Given a Codable struct payload — the type the legacy serializer rejected
        let request = ProxyRequestFixture(prompt: "Find restaurants", maxTokens: 8192, temperature: 0.2)

        // When encoding it to a JSON object graph
        let encoded = try FirebaseCloudFunctionsProvider.encodeToJSONObject(request)

        // Then the result is the dictionary/array/primitive graph the serializer accepts
        #expect(JSONSerialization.isValidJSONObject(encoded))
        let dictionary = encoded as? [String: Any]
        #expect(dictionary != nil)
        #expect(dictionary?["prompt"] as? String == "Find restaurants")
        #expect(dictionary?["maxTokens"] as? Int == 8192)
        #expect(dictionary?["response_schema"] is [String: Any])
    }

    @Test("Raw struct is not a valid JSON object — captures the original failure mode")
    func rawStruct_isNotValidJSONObject() {
        // Given the struct passed directly as Any — what the legacy call(_:) received
        let request = ProxyRequestFixture(prompt: "x", maxTokens: 1, temperature: 0)

        // Then the serializer's acceptance check rejects it — the FVRS-288 bug
        #expect(JSONSerialization.isValidJSONObject(request) == false)
    }
}
