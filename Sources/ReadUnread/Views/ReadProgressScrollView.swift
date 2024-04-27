//
//  ReadProgressScrollView.swift
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
					scroller.scrollTo(currentPosition, anchor: .bottom)
				}
			}
		}
	}
}

#if DEBUG
	struct TestItem: ReadUnreadable {
		struct Section: Identifiable, Hashable {
			let id: Int
			let height = Double.random(in: 20 ... 50)
			var idString: String { "\(id)" }
			let subsections: [Subsection]

			init(id: Int) {
				self.id = id
				self.subsections = Array(0 ... 2).map { Subsection(id: $0, parentID: id) }
			}
		}

		struct Subsection: Identifiable, Hashable {
			let id: Int
			let parentID: Int
			let height = Double.random(in: 10 ... 50)
			var idString: String { "\(id)" }
		}

		var id: String { "hi" }
		var readableID: String = "hi"
		var readableSectionCount: Int { sections.count }
		var sections = Array(0 ..< 200).map { Section(id: $0) }
	}

	struct ReadProgressScrollViewPreviewView: View {
		@State var visible: Set<Int> = [2]

		let item = TestItem()

		var body: some View {
			ReadProgressScrollView(item) {
				LazyVStack(spacing: 0) {
					ForEach(item.sections, id: \.idString) { section in
						HStack {
							VStack {
								HStack {
									Text("Section")
										.foregroundStyle(.secondary)
									Spacer()
									Text(section.id, format: .number)
										.bold()
								}
								.font(.title3)

								ForEach(section.subsections) { subsection in
									Rectangle()
										.fill(.tertiary)
										.frame(height: subsection.height)
										.readStatusSection(id: (section.id * 3) + subsection.id)
										.overlay {
											Text("\((section.id * 3) + subsection.id)")
												.font(.caption)
												.foregroundStyle(.secondary)
										}
								}
							}
							.padding()
						}

						Divider()
					}
				}
			}
			.safeAreaInset(edge: .bottom) {
				ReadCurrent(for: item) { current in
					Text("Current: \(current)")
						.monospacedDigit()
						.contentTransition(.numericText())
						.animation(.bouncy, value: current)
						.bold()
						.padding()
						.foregroundStyle(.white)
						.background(
							RoundedRectangle(cornerRadius: 12)
								.fill(.blue)
								.shadow(radius: 5)
						)
						.padding()
				}
			}
		}
	}

	#Preview {
		NavigationStack {
			ReadProgressScrollViewPreviewView()
				.navigationTitle("Preview")
		}
		.modelContainer(for: ReadStatusRecord.self, inMemory: true)
	}
#endif
