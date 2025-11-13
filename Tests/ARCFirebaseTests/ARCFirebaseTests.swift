import Testing
@testable import ARCFirebase

struct ARCFirebaseTests {
    @Test
    func testHelloFunction() {
        #expect(ARCFirebase.hello() == "Hello from ARCFirebase!")
    }
}
