//
//  File.swift
//  
//
//  Created by Pat Nakajima on 4/25/24.
//

import Foundation
import SwiftUI

public struct ReadProgressScrollView<Content: View, Readable: ReadUnreadable>: View {
	@Environment(\.modelContext) var modelContext

	var readable: Readable
	var content: () -> Content

	public init(_ readable: Readable, @ViewBuilder content: @escaping () -> Content) {
		self.readable = readable
		self.content = content
	}

	public var body: some View {
		ScrollViewReader { scroller in
			ScrollView {
				content()
					.scrollTargetLayout()
			}
			.readStatus(for: readable)
			.onAppear {
				if let currentPosition = try? ReadStatusRecord.current(for: readable, in: modelContext.container) {
					scroller.scrollTo(currentPosition)
				}
			}
		}
	}
}
