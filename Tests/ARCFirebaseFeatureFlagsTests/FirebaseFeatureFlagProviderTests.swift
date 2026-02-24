import Foundation
import Testing
@testable import ARCFirebaseFeatureFlags

@Suite("FirebaseFeatureFlagProvider Tests") struct FirebaseFeatureFlagProviderTests {
    // MARK: - Bool Tests

    @Test("Returns mock bool value when set") func boolValue_whenSet() {
        let mock = makeSUT()
        mock.mockFlags["dark_mode"] = true

        #expect(mock.bool(forKey: "dark_mode", defaultValue: false) == true)
    }

    @Test("Returns default bool value when key not set") func boolValue_whenNotSet() {
        let mock = makeSUT()

        #expect(mock.bool(forKey: "missing_key", defaultValue: false) == false)
        #expect(mock.bool(forKey: "missing_key", defaultValue: true) == true)
    }

    @Test("isEnabled convenience returns false by default") func isEnabled_defaultsFalse() {
        let mock = makeSUT()

        #expect(mock.isEnabled("unset_flag") == false)
    }

    @Test("isEnabled convenience returns mock value when set") func isEnabled_returnsMockValue() {
        let mock = makeSUT()
        mock.mockFlags["premium_feature"] = true

        #expect(mock.isEnabled("premium_feature") == true)
    }

    @Test("Bool convenience without default returns false") func boolConvenience_defaultsFalse() {
        let mock = makeSUT()

        #expect(mock.bool(forKey: "missing") == false)
    }

    // MARK: - String Tests

    @Test("Returns mock string value when set") func stringValue_whenSet() {
        let mock = makeSUT()
        mock.mockFlags["welcome_message"] = "Hello!"

        #expect(mock.string(forKey: "welcome_message", defaultValue: "") == "Hello!")
    }

    @Test("Returns default string value when key not set") func stringValue_whenNotSet() {
        let mock = makeSUT()

        #expect(mock.string(forKey: "missing", defaultValue: "fallback") == "fallback")
    }

    @Test("String convenience without default returns empty string") func stringConvenience_defaultsEmpty() {
        let mock = makeSUT()

        #expect(mock.string(forKey: "missing").isEmpty)
    }

    // MARK: - Int Tests

    @Test("Returns mock int value when set") func intValue_whenSet() {
        let mock = makeSUT()
        mock.mockFlags["max_retries"] = 5

        #expect(mock.int(forKey: "max_retries", defaultValue: 3) == 5)
    }

    @Test("Returns default int value when key not set") func intValue_whenNotSet() {
        let mock = makeSUT()

        #expect(mock.int(forKey: "missing", defaultValue: 42) == 42)
    }

    @Test("Int convenience without default returns zero") func intConvenience_defaultsZero() {
        let mock = makeSUT()

        #expect(mock.int(forKey: "missing") == 0)
    }

    // MARK: - Double Tests

    @Test("Returns mock double value when set") func doubleValue_whenSet() {
        let mock = makeSUT()
        mock.mockFlags["threshold"] = 0.75

        #expect(mock.double(forKey: "threshold", defaultValue: 0.5) == 0.75)
    }

    @Test("Returns default double value when key not set") func doubleValue_whenNotSet() {
        let mock = makeSUT()

        #expect(mock.double(forKey: "missing", defaultValue: 1.5) == 1.5)
    }

    @Test("Double convenience without default returns zero") func doubleConvenience_defaultsZero() {
        let mock = makeSUT()

        #expect(mock.double(forKey: "missing") == 0.0)
    }

    // MARK: - Data Tests

    @Test("Returns mock data value when set") func dataValue_whenSet() {
        let mock = makeSUT()
        let testData = Data("config-payload".utf8)
        mock.mockFlags["payload"] = testData

        #expect(mock.data(forKey: "payload", defaultValue: Data()) == testData)
    }

    @Test("Returns default data value when key not set") func dataValue_whenNotSet() {
        let mock = makeSUT()
        let fallback = Data("fallback".utf8)

        #expect(mock.data(forKey: "missing", defaultValue: fallback) == fallback)
    }

    @Test("Data convenience without default returns empty Data") func dataConvenience_defaultsEmpty() {
        let mock = makeSUT()

        #expect(mock.data(forKey: "missing") == Data())
    }

    // MARK: - Fetch and Activate Tests

    @Test("fetchAndActivate increments call count") func fetchAndActivate_incrementsCallCount() async throws {
        let mock = makeSUT()

        try await mock.fetchAndActivate()
        try await mock.fetchAndActivate()

        #expect(mock.fetchAndActivateCallCount == 2)
    }

    @Test("fetchAndActivate throws mock error when set") func fetchAndActivate_throwsMockError() async {
        let mock = makeSUT()
        mock.mockError = MockFeatureFlagError.fetchFailed

        do {
            try await mock.fetchAndActivate()
            Issue.record("Expected error to be thrown")
        } catch {
            #expect(error is MockFeatureFlagError)
        }
    }

    // MARK: - Set Defaults Tests

    @Test("setDefaults stores values and increments call count") func setDefaults_storesValues() {
        let mock = makeSUT()

        mock.setDefaults(["feature_a": true, "max_count": 10])

        #expect(mock.setDefaultsCallCount == 1)
        #expect(mock.bool(forKey: "feature_a") == true)
        #expect(mock.int(forKey: "max_count") == 10)
    }

    @Test("setDefaults does not overwrite existing mock flags") func setDefaults_doesNotOverwriteExisting() {
        let mock = makeSUT()
        mock.mockFlags["feature_a"] = true

        mock.setDefaults(["feature_a": false])

        #expect(mock.bool(forKey: "feature_a") == true)
    }

    // MARK: - Config Updates Stream Tests

    @Test("configUpdates yields when simulateConfigUpdate is called") func configUpdates_yieldsOnSimulate() async {
        let mock = makeSUT()
        let stream = mock.configUpdates()
        var iterator = stream.makeAsyncIterator()

        mock.simulateConfigUpdate()

        let result = await iterator.next()
        #expect(result != nil)
    }

    @Test("configUpdates finishes when finishConfigUpdates is called") func configUpdates_finishesStream() async {
        let mock = makeSUT()
        let stream = mock.configUpdates()
        var iterator = stream.makeAsyncIterator()

        mock.finishConfigUpdates()

        let result = await iterator.next()
        #expect(result == nil)
    }

    // MARK: - Reset Tests

    @Test("reset clears all mock state") func reset_clearsAllState() async {
        let mock = makeSUT()
        mock.mockFlags["key"] = true
        mock.mockError = MockFeatureFlagError.fetchFailed
        try? await mock.fetchAndActivate()
        mock.setDefaults(["a": 1])

        mock.reset()

        #expect(mock.mockFlags.isEmpty)
        #expect(mock.mockError == nil)
        #expect(mock.fetchAndActivateCallCount == 0)
        #expect(mock.setDefaultsCallCount == 0)
        #expect(mock.lastSetDefaults == nil)
    }

    // MARK: - Helpers

    private func makeSUT() -> MockFeatureFlagProvider {
        MockFeatureFlagProvider()
    }
}
