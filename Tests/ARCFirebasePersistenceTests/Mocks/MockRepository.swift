//
//  MockRepository.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import Foundation
import os
@testable import ARCFirebasePersistence

/// Mock repository for testing.
final class MockRepository<Entity: Identifiable & Codable & Sendable>: Repository where Entity.ID == String {
    private struct State {
        var storage: [String: Entity] = [:]
        var mockError: Error?
        var fetchCallCount: Int = 0
        var fetchAllCallCount: Int = 0
        var saveCallCount: Int = 0
        var updateCallCount: Int = 0
        var deleteCallCount: Int = 0
    }

    private let state = OSAllocatedUnfairLock(initialState: State())

    // MARK: - Mock State

    private var storage: [String: Entity] {
        get { state.withLock { $0.storage } }
        set { state.withLock { $0.storage = newValue } }
    }

    var mockError: Error? {
        state.withLock { $0.mockError }
    }

    // MARK: - Call Counts

    var fetchCallCount: Int {
        state.withLock { $0.fetchCallCount }
    }

    var fetchAllCallCount: Int {
        state.withLock { $0.fetchAllCallCount }
    }

    var saveCallCount: Int {
        state.withLock { $0.saveCallCount }
    }

    var updateCallCount: Int {
        state.withLock { $0.updateCallCount }
    }

    var deleteCallCount: Int {
        state.withLock { $0.deleteCallCount }
    }

    // MARK: - Repository Implementation

    func fetch(id: String) async throws -> Entity? {
        state.withLock { $0.fetchCallCount += 1 }

        if let error = mockError {
            throw error
        }

        return storage[id]
    }

    func fetchAll() async throws -> [Entity] {
        state.withLock { $0.fetchAllCallCount += 1 }

        if let error = mockError {
            throw error
        }

        return Array(storage.values)
    }

    func save(_ entity: Entity) async throws {
        state.withLock { $0.saveCallCount += 1 }

        if let error = mockError {
            throw error
        }

        state.withLock { $0.storage[entity.id] = entity }
    }

    func update(_ entity: Entity) async throws {
        state.withLock { $0.updateCallCount += 1 }

        if let error = mockError {
            throw error
        }

        state.withLock { $0.storage[entity.id] = entity }
    }

    func delete(id: String) async throws {
        state.withLock { $0.deleteCallCount += 1 }

        if let error = mockError {
            throw error
        }

        state.withLock { _ = $0.storage.removeValue(forKey: id) }
    }

    // MARK: - Test Helpers

    func reset() {
        state.withLock { $0.storage = [:] }
        state.withLock { $0.mockError = nil }
        state.withLock { $0.fetchCallCount = 0 }
        state.withLock { $0.fetchAllCallCount = 0 }
        state.withLock { $0.saveCallCount = 0 }
        state.withLock { $0.updateCallCount = 0 }
        state.withLock { $0.deleteCallCount = 0 }
    }

    func setMockError(_ error: Error?) {
        state.withLock { $0.mockError = error }
    }

    func setStorage(_ entities: [Entity]) {
        state.withLock { $0.storage = Dictionary(uniqueKeysWithValues: entities.map { ($0.id, $0) }) }
    }

    var count: Int {
        storage.count
    }

    var isEmpty: Bool {
        storage.isEmpty
    }
}
