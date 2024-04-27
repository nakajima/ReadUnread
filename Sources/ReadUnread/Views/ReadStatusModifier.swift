//
//  ReadStatusModifier.swift
//
//
//  Created by Pat Nakajima on 4/27/24.
//

import OSLog
import SwiftUI

private let logger = Logger(subsystem: "ReadUnread", category: "ReadStatusModifier")

@MainActor struct ReadStatusModifier<T: ReadUnreadable>: ViewModifier {
	@Environment(\.modelContext) var modelContext
	@Environment(\.scenePhase) var scenePhase
	@Environment(\.scrollObserver) var scrollObserver

	let readable: T

	init(readable: T) {
		self.readable = readable
	}

	func body(content: Content) -> some View {
		content
			.environment(\.scrollObserver, scrollObserver)
			.onChange(of: scenePhase) {
				if scenePhase != .active {
					saveProgress()
				}
			}
			.onDisappear {
				saveProgress()
			}
			.task { @MainActor in
				for await update in scrollObserver.stream() {
					saveProgress(current: update)
				}
			}
	}

	@MainActor private func saveProgress(current: Int? = nil) {
		logger.trace("saving progress for \(readable.readableID): \(current ?? -1)")

		try? ReadStatusRecord.update(
			current: current ?? scrollObserver.currentValue,
			total: readable.readableSectionCount,
			readable: readable,
			in: modelContext.container
		)
	}
}

public extension View {
	@MainActor func readStatus<T: ReadUnreadable>(for readable: T) -> some View {
		modifier(ReadStatusModifier(readable: readable))
	}
}
