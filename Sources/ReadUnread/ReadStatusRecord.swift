//
//  ReadStatusRecord.swift
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

	public init(readable: any ReadUnreadable) {
		self.readableID = readable.readableID
	}

	@MainActor public static func current<T: ReadUnreadable>(for readable: T, in container: ModelContainer) throws -> Int? {
		let readableID = readable.readableID
		let descriptor = FetchDescriptor<ReadStatusRecord>(predicate: #Predicate { $0.readableID == readableID })
		return try container.mainContext.fetch(descriptor).first?.current
	}

	@MainActor public static func update<T: ReadUnreadable>(current: Int, total: Int, readable: T, in container: ModelContainer) throws {
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
