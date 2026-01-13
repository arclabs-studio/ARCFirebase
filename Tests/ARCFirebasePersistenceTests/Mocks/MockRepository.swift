//
//  MockRepository.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import Foundation
@testable import ARCFirebasePersistence

/// Mock repository for testing.
final class MockRepository<Entity: Identifiable & Codable>: Repository, @unchecked Sendable where Entity.ID == String {
    // MARK: - Mock State

    private var storage: [String: Entity] = [:]
    var mockError: Error?

    // MARK: - Call Counts

    private(set) var fetchCallCount = 0
    private(set) var fetchAllCallCount = 0
    private(set) var saveCallCount = 0
    private(set) var updateCallCount = 0
    private(set) var deleteCallCount = 0

    // MARK: - Repository Implementation

    func fetch(id: String) async throws -> Entity? {
        fetchCallCount += 1

        if let error = mockError {
            throw error
        }

        return storage[id]
    }

    func fetchAll() async throws -> [Entity] {
        fetchAllCallCount += 1

        if let error = mockError {
            throw error
        }

        return Array(storage.values)
    }

    func save(_ entity: Entity) async throws {
        saveCallCount += 1

        if let error = mockError {
            throw error
        }

        storage[entity.id] = entity
    }

    func update(_ entity: Entity) async throws {
        updateCallCount += 1

        if let error = mockError {
            throw error
        }

        storage[entity.id] = entity
    }

    func delete(id: String) async throws {
        deleteCallCount += 1

        if let error = mockError {
            throw error
        }

        storage.removeValue(forKey: id)
    }

    // MARK: - Test Helpers

    func reset() {
        storage = [:]
        mockError = nil
        fetchCallCount = 0
        fetchAllCallCount = 0
        saveCallCount = 0
        updateCallCount = 0
        deleteCallCount = 0
    }

    func setMockError(_ error: Error?) {
        mockError = error
    }

    func setStorage(_ entities: [Entity]) {
        storage = Dictionary(uniqueKeysWithValues: entities.map { ($0.id, $0) })
    }

    var count: Int {
        storage.count
    }

    var isEmpty: Bool {
        storage.isEmpty
    }
}
