import Testing
@testable import ARCFirebaseStorage

@Suite("StorageManager Tests")
struct StorageManagerTests {

    @Test("StorageManager is a singleton")
    func storageManagerSingleton() {
        let manager1 = StorageManager.shared
        let manager2 = StorageManager.shared

        #expect(manager1 === manager2)
    }

    @Test("StorageReference initialization with bucket")
    func storageReferenceInitialization() {
        let ref = StorageReference(
            bucket: "test-bucket",
            path: "photos/image.jpg"
        )

        #expect(ref.bucket == "test-bucket")
        #expect(ref.path == "photos/image.jpg")
        #expect(ref.fullPath == "test-bucket/photos/image.jpg")
    }

    @Test("StorageReference initialization without bucket")
    func storageReferenceWithoutBucket() {
        let ref = StorageReference(
            bucket: nil,
            path: "photos/image.jpg"
        )

        #expect(ref.bucket == nil)
        #expect(ref.path == "photos/image.jpg")
        #expect(ref.fullPath == "photos/image.jpg")
    }

    @Test("Restaurant photo reference helper")
    func restaurantPhotoReference() {
        let ref = StorageReference.restaurantPhoto(
            restaurantID: "abc123",
            filename: "photo.jpg"
        )

        #expect(ref.path == "restaurants/abc123/photos/photo.jpg")
    }

    @Test("User profile photo reference helper")
    func userProfilePhotoReference() {
        let ref = StorageReference.userProfilePhoto(userID: "user456")

        #expect(ref.path == "users/user456/profile.jpg")
    }
}
