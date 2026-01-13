import Testing
@testable import ARCFirebaseCrashlytics

@Suite("CrashlyticsManager Tests")
struct CrashlyticsManagerTests {

    @Test("CrashlyticsManager is a singleton")
    func crashlyticsManagerSingleton() {
        let manager1 = CrashlyticsManager.shared
        let manager2 = CrashlyticsManager.shared

        #expect(manager1 === manager2)
    }

    @Test("Manager instance exists")
    func managerExists() {
        // Verify the manager can be accessed
        let manager = CrashlyticsManager.shared
        #expect(manager != nil)
    }
}
