import XCTest
@testable import ARCFirebaseStorage

final class StorageManagerTests: XCTestCase {

    func testStorageManagerSingleton() {
        let manager1 = StorageManager.shared
        let manager2 = StorageManager.shared

        XCTAssertTrue(manager1 === manager2, "StorageManager should be a singleton")
    }

    func testStorageReferenceInitialization() {
        let ref = StorageReference(
            bucket: "test-bucket",
            path: "photos/image.jpg"
        )

        XCTAssertEqual(ref.bucket, "test-bucket")
        XCTAssertEqual(ref.path, "photos/image.jpg")
        XCTAssertEqual(ref.fullPath, "test-bucket/photos/image.jpg")
    }

    func testStorageReferenceWithoutBucket() {
        let ref = StorageReference(
            bucket: nil,
            path: "photos/image.jpg"
        )

        XCTAssertNil(ref.bucket)
        XCTAssertEqual(ref.path, "photos/image.jpg")
        XCTAssertEqual(ref.fullPath, "photos/image.jpg")
    }

    func testRestaurantPhotoReference() {
        let ref = StorageReference.restaurantPhoto(
            restaurantID: "abc123",
            filename: "photo.jpg"
        )

        XCTAssertEqual(ref.path, "restaurants/abc123/photos/photo.jpg")
    }

    func testUserProfilePhotoReference() {
        let ref = StorageReference.userProfilePhoto(userID: "user456")

        XCTAssertEqual(ref.path, "users/user456/profile.jpg")
    }
}
