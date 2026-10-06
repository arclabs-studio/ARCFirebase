//
//  FeatureFlagStoreTests.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-10-05.
//

import Foundation
import Testing
@testable import ARCFirebaseFeatureFlags

@Suite("FeatureFlagStore Tests", .tags(.unit)) struct FeatureFlagStoreTests {
    // MARK: - Initial State

    @Test("A freshly created store exposes the provided snapshot and has no subscribers")
    func init_exposesProvidedSnapshotAndNoSubscribers() {
        // Given
        let initial = FeatureFlagSnapshot(remoteValues: ["a": Data("1".utf8)])

        // When
        let sut = makeSUT(snapshot: initial)

        // Then
        #expect(sut.snapshot == initial)
        #expect(sut.hasSubscribers == false)
    }

    // MARK: - replaceDefaults

    @Test("replaceDefaults updates the snapshot's defaults while keeping the remote values")
    func replaceDefaults_updatesSnapshotDefaultsKeepingRemoteValues() {
        // Given
        let sut = makeSUT(snapshot: FeatureFlagSnapshot(remoteValues: ["remote": Data("kept".utf8)]))

        // When
        sut.replaceDefaults(["threshold": 10])

        // Then
        #expect(sut.snapshot.int(forKey: "threshold", defaultValue: -1) == 10)
        #expect(sut.snapshot.data(forKey: "remote", defaultValue: Data()) == Data("kept".utf8))
    }

    @Test("replaceDefaults does not notify subscribers") func replaceDefaults_doesNotNotifySubscribers() async {
        // Given — subscribe before mutating, so registration happens synchronously
        let sut = makeSUT()
        let stream = sut.updates()
        let task = Task {
            var count = 0
            for await _ in stream {
                count += 1
            }
            return count
        }

        // When — a default change followed by exactly one real publish
        sut.replaceDefaults(["a": true])
        sut.publishRemoteValues(["b": Data()])
        task.cancel()

        // Then — only the publish produced a yield
        #expect(await task.value == 1)
    }

    // MARK: - publishRemoteValues

    @Test("publishRemoteValues updates the snapshot's remote values while keeping the defaults")
    func publishRemoteValues_updatesSnapshotRemoteValuesKeepingDefaults() {
        // Given
        let sut = makeSUT()
        sut.replaceDefaults(["kept": "default"])

        // When
        sut.publishRemoteValues(["fresh": Data("value".utf8)])

        // Then
        #expect(sut.snapshot.data(forKey: "fresh", defaultValue: Data()) == Data("value".utf8))
        #expect(sut.snapshot.string(forKey: "kept", defaultValue: "") == "default")
    }

    @Test("publishRemoteValues yields exactly once per publish to every live subscriber", .tags(.critical))
    func publishRemoteValues_yieldsOncePerPublishToEverySubscriber() async {
        // Given — two independent subscribers, registered synchronously
        let sut = makeSUT()
        let streamA = sut.updates()
        let streamB = sut.updates()
        let taskA = Task {
            var count = 0
            for await _ in streamA {
                count += 1
            }
            return count
        }
        let taskB = Task {
            var count = 0
            for await _ in streamB {
                count += 1
            }
            return count
        }

        // When — two separate publishes
        sut.publishRemoteValues(["k": Data("1".utf8)])
        sut.publishRemoteValues(["k": Data("2".utf8)])
        taskA.cancel()
        taskB.cancel()

        // Then — each subscriber received one yield per publish
        #expect(await taskA.value == 2)
        #expect(await taskB.value == 2)
    }

    // MARK: - Termination

    @Test("A terminated subscriber stops receiving updates while others keep receiving them")
    func terminatedSubscriber_stopsReceivingWhileOthersContinue() async {
        // Given
        let sut = makeSUT()
        let stoppedStream = sut.updates()
        let continuingStream = sut.updates()
        let stoppedTask = Task {
            var count = 0
            for await _ in stoppedStream {
                count += 1
            }
            return count
        }
        let continuingTask = Task {
            var count = 0
            for await _ in continuingStream {
                count += 1
            }
            return count
        }

        // When — the first subscriber is torn down before anything is published
        stoppedTask.cancel()
        _ = await stoppedTask.value
        sut.publishRemoteValues(["k": Data()])
        continuingTask.cancel()

        // Then — the surviving subscriber still saw the publish
        #expect(await continuingTask.value == 1)
    }

    // MARK: - hasSubscribers

    @Test("hasSubscribers reflects the live subscriber count through the whole lifecycle")
    func hasSubscribers_transitionsAsSubscribersComeAndGo() async {
        // Given
        let sut = makeSUT()
        #expect(sut.hasSubscribers == false)

        // When — first subscriber arrives
        let streamA = sut.updates()
        let taskA = Task { for await _ in streamA {} }
        #expect(sut.hasSubscribers == true)

        // When — a second subscriber arrives
        let streamB = sut.updates()
        let taskB = Task { for await _ in streamB {} }
        #expect(sut.hasSubscribers == true)

        // When — one of two leaves
        taskA.cancel()
        await taskA.value
        #expect(sut.hasSubscribers == true)

        // When — the last one leaves
        taskB.cancel()
        await taskB.value
        #expect(sut.hasSubscribers == false)
    }

    // MARK: - onSubscribersChanged

    @Test("onSubscribersChanged fires true on the first arrival and false on the last departure, never in between",
          .tags(.critical))
    func onSubscribersChanged_firesOnFirstArrivalAndLastDeparture_butNotMiddleTransitions() async {
        // Given
        let recorder = SubscriberChangeRecorder()
        let sut = makeSUT(onSubscribersChanged: { recorder.record($0) })

        // When — first subscriber arrives
        let streamA = sut.updates()
        #expect(recorder.values == [true])

        // When — a second subscriber arrives (0 -> 1 already happened; this is 1 -> 2)
        let streamB = sut.updates()
        #expect(recorder.values == [true])

        // When — one of two leaves (2 -> 1)
        let taskA = Task { for await _ in streamA {} }
        taskA.cancel()
        await taskA.value
        #expect(recorder.values == [true])

        // When — the last one leaves (1 -> 0)
        let taskB = Task { for await _ in streamB {} }
        taskB.cancel()
        await taskB.value

        // Then
        #expect(recorder.values == [true, false])
    }

    // MARK: - Deinitialization

    @Test("Releasing the store finishes every live stream instead of leaving consumers waiting",
          .timeLimit(.minutes(1)))
    func deinit_finishesLiveStreams() async {
        // Given
        var sut: FeatureFlagStore? = makeSUT()
        let first = sut?.updates()
        let second = sut?.updates()
        var firstIterator = first?.makeAsyncIterator()
        var secondIterator = second?.makeAsyncIterator()

        // When
        sut = nil

        // Then
        let firstResult: Void? = await firstIterator?.next()
        let secondResult: Void? = await secondIterator?.next()
        #expect(firstResult == nil)
        #expect(secondResult == nil)
    }

    // MARK: - Concurrency Safety

    @Test("Concurrent publishes never leave the snapshot in a torn state", .tags(.critical))
    func concurrentPublishes_leaveSnapshotWithoutTornState() async {
        // Given
        let sut = makeSUT()

        // When — 100 tasks race to publish two keys that must always agree within a single publish
        await withTaskGroup(of: Void.self) { group in
            for index in 0 ..< 100 {
                group.addTask {
                    let tag = Data(String(index).utf8)
                    sut.publishRemoteValues(["a": tag, "b": tag])
                }
            }
        }

        // Then — whichever publish won, both keys reflect it — never a mix of two different publishes
        let snapshot = sut.snapshot
        #expect(snapshot.data(forKey: "a", defaultValue: Data()) == snapshot.data(forKey: "b", defaultValue: Data()))
    }

    // MARK: - Helpers

    private func makeSUT(snapshot: FeatureFlagSnapshot = FeatureFlagSnapshot(),
                         onSubscribersChanged: @escaping @Sendable (_ hasSubscribers: Bool) -> Void = { _ in })
        -> FeatureFlagStore {
        FeatureFlagStore(snapshot: snapshot, onSubscribersChanged: onSubscribersChanged)
    }
}
