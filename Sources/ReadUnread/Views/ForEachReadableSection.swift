//
//  ForEachReadableSection.swift
//
//
//  Created by Pat Nakajima on 4/25/24.
//

import SwiftUI

public struct ForEachReadableSection<T, Content: View>: View {
	var sections: [T]
	var content: (T) -> Content

	public init(_ sections: [T], @ViewBuilder content: @escaping (T) -> Content) {
		self.sections = sections
		self.content = content
	}

	public var body: some View {
		ForEach(Array(sections.enumerated()), id: \.0) { i, section in
			content(section)
			ReadProgressMarker(id: i)
		}

		Rectangle()
			.fill(.clear)
			.frame(height: 64)
			.id(sections.count + 1)
	}
}
