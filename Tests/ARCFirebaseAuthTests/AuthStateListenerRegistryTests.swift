//
//  AuthStateListenerRegistryTests.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-11-06.
//

import Foundation
import Testing
@testable import ARCFirebaseAuth

@MainActor
@Suite("AuthStateListenerRegistry Tests", .tags(.unit)) struct AuthStateListenerRegistryTests {
    // MARK: - Registration

    @Test("Registering adds one listener that forwards auth changes to the stream", .tags(.critical))
    func registerForwardsChanges() async {
        // Given
        let (spy, sut) = makeSUT()
        let (stream, continuation) = AsyncStream<User?>.makeStream()
        let user = User(id: "uid-1", email: "test@example.com")

        // When
        sut.register(UUID(), continuation: continuation)
        spy.emit(user)
        continuation.finish()

        // Then
        var received: [User?] = []
        for await value in stream {
            received.append(value)
        }
        #expect(spy.addedHandles.count == 1)
        #expect(received.map { $0?.id } == ["uid-1"])
    }

    @Test("Unregistering removes exactly the handle that registration returned", .tags(.critical))
    func unregisterRemovesRegisteredHandle() {
        // Given
        let (spy, sut) = makeSUT()
        let id = UUID()
        let (_, continuation) = AsyncStream<User?>.makeStream()
        sut.register(id, continuation: continuation)

        // When
        sut.unregister(id)

        // Then
        #expect(spy.removedHandles.count == 1)
        #expect(spy.removedHandles.first === spy.addedHandles.first)
    }

    @Test("Unregistering twice removes the listener only once") func unregisterTwiceRemovesOnce() {
        // Given
        let (spy, sut) = makeSUT()
        let id = UUID()
        let (_, continuation) = AsyncStream<User?>.makeStream()
        sut.register(id, continuation: continuation)

        // When
        sut.unregister(id)
        sut.unregister(id)

        // Then
        #expect(spy.removedHandles.count == 1)
    }

    @Test("Each stream receives only its own listener's changes", .tags(.critical)) func streamsAreIsolated() async {
        // Given
        let (spy, sut) = makeSUT()
        let (firstStream, firstContinuation) = AsyncStream<User?>.makeStream()
        let (secondStream, secondContinuation) = AsyncStream<User?>.makeStream()
        sut.register(UUID(), continuation: firstContinuation)
        sut.register(UUID(), continuation: secondContinuation)

        // When
        spy.emit(User(id: "uid-1"), toListenerAt: 0)
        spy.emit(User(id: "uid-2"), toListenerAt: 1)
        firstContinuation.finish()
        secondContinuation.finish()

        // Then
        var first: [String?] = []
        for await value in firstStream {
            first.append(value?.id)
        }
        var second: [String?] = []
        for await value in secondStream {
            second.append(value?.id)
        }
        #expect(first == ["uid-1"])
        #expect(second == ["uid-2"])
    }

    // MARK: - Termination Before Registration

    @Test("A stream that terminated before registering never adds a listener", .tags(.critical))
    func terminationBeforeRegistrationSkipsListener() {
        // Given
        let (spy, sut) = makeSUT()
        let id = UUID()
        let (_, continuation) = AsyncStream<User?>.makeStream()

        // When
        sut.unregister(id)
        sut.register(id, continuation: continuation)

        // Then
        #expect(spy.addedHandles.isEmpty)
        #expect(spy.removedHandles.isEmpty)
    }

    @Test("Skipping a late registration does not affect other streams") func skippedRegistrationIsolatedPerID() {
        // Given
        let (spy, sut) = makeSUT()
        let terminated = UUID()
        let (_, continuation) = AsyncStream<User?>.makeStream()
        sut.unregister(terminated)

        // When
        sut.register(terminated, continuation: continuation)
        sut.register(UUID(), continuation: continuation)

        // Then
        #expect(spy.addedHandles.count == 1)
    }

    // MARK: - Helpers

    private func makeSUT() -> (AuthListenerSpy, AuthStateListenerRegistry) {
        let spy = AuthListenerSpy()
        return (spy, spy.makeRegistry())
    }
}
