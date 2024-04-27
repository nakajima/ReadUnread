//
//  ReadCurrent.swift
//
//
//  Created by Pat Nakajima on 4/27/24.
//

import SwiftData
import SwiftUI

public struct ReadCurrent<Content: View, T: ReadUnreadable>: View {
	var readable: T
	@ViewBuilder var content: (Int) -> Content

	@Query var records: [ReadStatusRecord]

	public init(for readable: T, content: @escaping (Int) -> Content) {
		self.readable = readable
		self.content = content

		let readableID = readable.readableID
		self._records = Query(filter: #Predicate { $0.readableID == readableID })
	}

	public var body: some View {
		content(record?.current ?? 0)
	}

	var record: ReadStatusRecord? {
		records.first
	}
}
