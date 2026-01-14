//
//  FirestoreRepositoryTests.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import Foundation
import Testing
@testable import ARCFirebasePersistence

@Suite("FirestoreRepository Tests")
struct FirestoreRepositoryTests {
    // MARK: - Test Entity

    struct TestEntity: Identifiable, Codable, Equatable {
        let id: String
        let name: String
        let value: Int
    }

    // MARK: - FirestoreDocument Protocol Tests

    @Test("FirestoreDocument protocol requirements")
    func firestoreDocumentProtocol() {
        struct TestDocument: FirestoreDocument {
            let id: String
            let createdAt: Date
            let updatedAt: Date
        }

        let now = Date()
        let document = TestDocument(
            id: "test123",
            createdAt: now,
            updatedAt: now
        )

        #expect(document.id == "test123")
        #expect(document.createdAt == now)
        #expect(document.updatedAt == now)
    }

    @Test("withTimestamps helper creates document with timestamps")
    func withTimestampsHelper() {
        struct TestDocument: FirestoreDocument {
            let id: String
            let createdAt: Date
            let updatedAt: Date
        }

        let document = TestDocument.withTimestamps { now in
            TestDocument(id: "test", createdAt: now, updatedAt: now)
        }

        #expect(document.id == "test")
    }

    // MARK: - Mock Repository Tests

    @Test("Mock repository can save entity")
    func save_withValidEntity_savesSuccessfully() async throws {
        let repository = MockRepository<TestEntity>()
        let entity = TestEntity(id: "1", name: "Test", value: 100)

        try await repository.save(entity)

        #expect(repository.saveCallCount == 1)
        #expect(repository.count == 1)
    }

    @Test("Mock repository can fetch entity by ID")
    func fetch_withExistingID_returnsEntity() async throws {
        let repository = MockRepository<TestEntity>()
        let entity = TestEntity(id: "1", name: "Test", value: 100)
        try await repository.save(entity)

        let fetched = try await repository.fetch(id: "1")

        #expect(repository.fetchCallCount == 1)
        #expect(fetched?.id == "1")
        #expect(fetched?.name == "Test")
    }

    @Test("Mock repository returns nil for non-existent entity")
    func fetch_withNonExistentID_returnsNil() async throws {
        let repository = MockRepository<TestEntity>()

        let fetched = try await repository.fetch(id: "non-existent")

        #expect(fetched == nil)
    }

    @Test("Mock repository can fetch all entities")
    func fetchAll_withMultipleEntities_returnsAll() async throws {
        let repository = MockRepository<TestEntity>()
        let entities = [
            TestEntity(id: "1", name: "First", value: 1),
            TestEntity(id: "2", name: "Second", value: 2),
            TestEntity(id: "3", name: "Third", value: 3)
        ]

        for entity in entities {
            try await repository.save(entity)
        }

        let all = try await repository.fetchAll()

        #expect(repository.fetchAllCallCount == 1)
        #expect(all.count == 3)
    }

    @Test("Mock repository can update entity")
    func update_withExistingEntity_updatesSuccessfully() async throws {
        let repository = MockRepository<TestEntity>()
        let original = TestEntity(id: "1", name: "Original", value: 100)
        try await repository.save(original)

        let updated = TestEntity(id: "1", name: "Updated", value: 200)
        try await repository.update(updated)

        let fetched = try await repository.fetch(id: "1")

        #expect(repository.updateCallCount == 1)
        #expect(fetched?.name == "Updated")
        #expect(fetched?.value == 200)
    }

    @Test("Mock repository can delete entity")
    func delete_withExistingID_deletesSuccessfully() async throws {
        let repository = MockRepository<TestEntity>()
        let entity = TestEntity(id: "1", name: "Test", value: 100)
        try await repository.save(entity)

        try await repository.delete(id: "1")

        let fetched = try await repository.fetch(id: "1")

        #expect(repository.deleteCallCount == 1)
        #expect(fetched == nil)
    }

    @Test("Mock repository throws configured error on fetch")
    func fetch_withMockError_throwsError() async {
        let repository = MockRepository<TestEntity>()
        let testError = NSError(domain: "TestDomain", code: 404, userInfo: nil)
        repository.setMockError(testError)

        do {
            _ = try await repository.fetch(id: "1")
            #expect(Bool(false), "Expected error to be thrown")
        } catch {
            #expect((error as NSError).code == 404)
        }
    }

    @Test("Mock repository throws configured error on save")
    func save_withMockError_throwsError() async {
        let repository = MockRepository<TestEntity>()
        let testError = NSError(domain: "TestDomain", code: 500, userInfo: nil)
        repository.setMockError(testError)
        let entity = TestEntity(id: "1", name: "Test", value: 100)

        do {
            try await repository.save(entity)
            #expect(Bool(false), "Expected error to be thrown")
        } catch {
            #expect((error as NSError).code == 500)
        }
    }

    @Test("Mock repository reset clears all state")
    func reset_afterOperations_clearsAllState() async throws {
        let repository = MockRepository<TestEntity>()
        let entity = TestEntity(id: "1", name: "Test", value: 100)

        try await repository.save(entity)
        _ = try await repository.fetch(id: "1")
        _ = try await repository.fetchAll()

        repository.reset()

        #expect(repository.saveCallCount == 0)
        #expect(repository.fetchCallCount == 0)
        #expect(repository.fetchAllCallCount == 0)
        #expect(repository.isEmpty)
    }

    @Test("Mock repository setStorage initializes with entities")
    func setStorage_withEntities_initializesCorrectly() async throws {
        let repository = MockRepository<TestEntity>()
        let entities = [
            TestEntity(id: "1", name: "First", value: 1),
            TestEntity(id: "2", name: "Second", value: 2)
        ]

        repository.setStorage(entities)

        let all = try await repository.fetchAll()
        #expect(all.count == 2)
    }

    // MARK: - Repository Protocol Tests

    @Test("Repository protocol exists and is accessible")
    func repositoryProtocolExists() {
        let repository: any Repository = MockRepository<TestEntity>()
        #expect(repository is MockRepository<TestEntity>)
    }
}
