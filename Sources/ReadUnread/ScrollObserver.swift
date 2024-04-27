//
//  ScrollObserver.swift
//  ReadUnread
//
//  Created by Pat Nakajima on 4/20/24.
//

import AsyncAlgorithms
import Foundation
import OSLog
import SwiftUI

private nonisolated(unsafe) let logger = Logger(subsystem: "ReadUnread", category: "ReadStatusModifier")

private struct ScrollObserverKey: EnvironmentKey {
	@MainActor static let defaultValue: ScrollObserver = .init(debounce: .seconds(0.2))
}

public extension EnvironmentValues {
	var scrollObserver: ScrollObserver {
		get { self[ScrollObserverKey.self] }
		set { self[ScrollObserverKey.self] = newValue }
	}
}

struct MaximumSet {
	var first: Int?
	var storage: Set<Int> = []

	mutating func insert(_ element: Int) {
		storage.insert(element)

		if let first, first > element {
			self.first = element
		} else if first == nil {
			first = element
		}
	}

	mutating func remove(_ element: Int) {
		storage.remove(element)

		if let first, element == first {
			self.first = storage.sorted().first
		} else if first == nil {
			first = element
		}
	}
}

@MainActor public final class ScrollObserver {
	public typealias Value = Set<Int>

	var set = MaximumSet()
	var _stream: AsyncDebounceSequence<AsyncStream<Int>, ContinuousClock>?
	var continuation: AsyncStream<Int>.Continuation?

	var debounce: Duration
	public var currentValue: Int = 0

	public init(debounce: Duration) {
		self.debounce = debounce
	}

	public func stream() -> AsyncDebounceSequence<AsyncStream<Int>, ContinuousClock> {
		if let continuation {
			continuation.finish()
		}

		let (stream, continuation) = AsyncStream<Int>.makeStream(bufferingPolicy: .bufferingNewest(1))
		let debounced = stream.debounce(for: debounce)
		_stream = debounced
		self.continuation = continuation

		return debounced
	}

	public func didShow(id: Int) {
		set.insert(id)

		if let max = set.first {
			continuation?.yield(max)
		}
	}

	public func didHide(id: Int) {
		set.remove(id)

		if let max = set.first {
			continuation?.yield(max)
		}
	}
}
