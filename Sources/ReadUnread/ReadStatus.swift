//
//  ReadStatus.swift
//
//
//  Created by Pat Nakajima on 4/25/24.
//

import Foundation
import Observation
import SwiftData
import SwiftUI

public protocol ReadUnreadable: Identifiable where ID: Codable {
	var readableID: String { get }
	var readableSectionCount: Int { get }
}

@Model public final class ReadStatusRecord {
	public var readableID: String
	public var updatedAt: Date = Date.distantPast
	public var current: Int = 0
	public var total: Int = 1
	public var progress: Double = 0

	init(readable: any ReadUnreadable) {
		self.readableID = readable.readableID
	}

	@MainActor static func update<T: ReadUnreadable>(current: Int, total: Int, readable: T, in container: ModelContainer) throws {
		let readableID = readable.readableID
		let descriptor = FetchDescriptor<ReadStatusRecord>(predicate: #Predicate { $0.readableID == readableID })
		let record = try container.mainContext.fetch(descriptor).first ?? {
			let record = ReadStatusRecord(readable: readable)
			container.mainContext.insert(record)
			return record
		}()

		record.current = current
		record.total = total
		record.updatedAt = Date()
		record.progress = Double(current) / max(1, Double(total)) // Prevent divide by zero

		try container.mainContext.save()
	}
}

@MainActor struct ReadStatusModifier<T: ReadUnreadable>: ViewModifier {
	@Environment(\.modelContext) var modelContext

	let readable: T
	let scrollObserver: ScrollObserver<Int>

	init(readable: T) {
		self.readable = readable
		self.scrollObserver = ScrollObserver(debounce: .seconds(0.2))
	}

	func body(content: Content) -> some View {
		content
			.scrollPosition(id: scrollObserver.position, anchor: .bottom)
			.task(priority: .low) { @MainActor in
				for await update in scrollObserver.stream() {
					try? ReadStatusRecord.update(current: update, total: readable.readableSectionCount, readable: readable, in: modelContext.container)
				}
			}
	}
}

public extension View {
	@MainActor func readStatus<T: ReadUnreadable>(for readable: T) -> some View {
		modifier(ReadStatusModifier(readable: readable))
	}
}
