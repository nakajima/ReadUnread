//
//  ReadProgress.swift
//
//
//  Created by Pat Nakajima on 4/25/24.
//

import SwiftData
import SwiftUI

public struct ReadProgress<Content: View, T: ReadUnreadable>: View {
	var readable: T
	@ViewBuilder var content: (Double) -> Content

	@Query var records: [ReadStatusRecord]

	public init(for readable: T, content: @escaping (Double) -> Content) {
		self.readable = readable
		self.content = content

		let readableID = readable.readableID
		self._records = Query(filter: #Predicate { $0.readableID == readableID })
	}

	public var body: some View {
		content(min(1, max(0, record?.progress ?? 0)))
	}

	var record: ReadStatusRecord? {
		records.first
	}
}
