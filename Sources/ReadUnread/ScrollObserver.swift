//
//  ScrollObserver.swift
//  ReadUnread
//
//  Created by Pat Nakajima on 4/20/24.
//

import AsyncAlgorithms
import Foundation
import SwiftUI

/// Use the ``position`` binding to read updates from [`scrollPosition(id:anchor:)`](https://developer.apple.com/documentation/swiftui/view/scrollposition(id:anchor:)),
/// then use the ``stream()`` method to process them.
@MainActor public final class ScrollObserver<Element: Equatable & Sendable> {
	var _stream: AsyncDebounceSequence<AsyncStream<Element>, ContinuousClock>?
	var continuation: AsyncStream<Element>.Continuation?

	var debounce: Duration
	public var currentValue: Element?

	public init(debounce: Duration) {
		self.debounce = debounce
	}

	public func stream() -> AsyncDebounceSequence<AsyncStream<Element>, ContinuousClock> {
		if let continuation {
			continuation.finish()
		}

		let (stream, continuation) = AsyncStream<Element>.makeStream(bufferingPolicy: .bufferingNewest(1))
		let debounced = stream.debounce(for: debounce)
		_stream = debounced
		self.continuation = continuation

		return debounced
	}

	public lazy var position = Binding<Element?>(
		get: {
			nil
		},
		set: { newValue in
			guard let newValue else { return }

			self.currentValue = newValue
			self.continuation?.yield(newValue)
		}
	)
}
