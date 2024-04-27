//
//  ReadStatusSectionModifier.swift
//
//
//  Created by Pat Nakajima on 4/27/24.
//

import SwiftUI

public struct ReadStatusSectionModifier: ViewModifier {
	var id: Int

	@Environment(\.scrollObserver) var scrollObserver

	public init(id: Int) {
		self.id = id
	}

	public func body(content: Content) -> some View {
		content
			.overlay(alignment: .bottom) {
				LazyVStack {
					Rectangle()
						.fill(.clear)
						.onAppear {
							scrollObserver.didShow(id: id)
						}
						.onDisappear {
							scrollObserver.didHide(id: id)
						}
				}
				.frame(height: 1)
				.padding(.top, 64)
			}
	}
}

public extension View {
	func readStatusSection(id: Int) -> some View {
		modifier(ReadStatusSectionModifier(id: id))
	}
}
