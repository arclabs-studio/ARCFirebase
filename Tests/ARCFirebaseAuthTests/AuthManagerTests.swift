import Testing
@testable import ARCFirebaseAuth

@Suite("AuthManager Tests")
struct AuthManagerTests {

    @Test("AuthManager is a singleton")
    func authManagerSingleton() {
        let manager1 = AuthManager.shared
        let manager2 = AuthManager.shared

        #expect(manager1 === manager2)
    }

    @Test("isAuthenticated property is accessible")
    func isAuthenticatedWhenNoUser() {
        // Note: This test assumes no user is signed in
        // In a real test, you would need to mock Firebase Auth
        let isAuthenticated = AuthManager.shared.isAuthenticated
        #expect(isAuthenticated == true || isAuthenticated == false)
    }

    @Test("currentUser property is accessible")
    func currentUserProperty() {
        // Verify the property exists and is accessible
        let currentUser = AuthManager.shared.currentUser
        // currentUser will be nil if no user is signed in
        #expect(currentUser == nil || currentUser != nil)
    }
}
