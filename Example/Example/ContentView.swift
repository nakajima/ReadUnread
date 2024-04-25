//
//  ContentView.swift
//  Example
//
//  Created by Pat Nakajima on 4/25/24.
//

import ReadUnread
import SwiftData
import SwiftUI

private struct LilGaugeStyle: GaugeStyle {
	func makeBody(configuration: GaugeStyleConfiguration) -> some View {
		ZStack {
			Circle()
				.stroke(.quinary, lineWidth: 2)
				.frame(width: 16, height: 16)
			Circle()
				.trim(from: 0, to: CGFloat(configuration.value))
				.stroke(.green, lineWidth: 2)
				.frame(width: 16, height: 16)
				.rotationEffect(Angle(degrees: -90))
				.overlay {
					if configuration.value >= 1 {
						Image(systemName: "checkmark")
							.resizable()
							.scaledToFit()
							.padding(4)
							.fontWeight(.heavy)
							.font(.caption2)
					}
				}
		}
		.animation(.bouncy, value: configuration.value)
	}
}

struct ItemView: View {
	var item: Item

	var body: some View {
		ScrollView {
			LazyVStack(alignment: .leading, spacing: 16) {
				ForEachReadableSection(item.sections) { section in
					Text(section)
				}
			}
			.padding()
			.scrollTargetLayout()
		}
		.readStatus(for: item)
		.navigationTitle(item.timestamp.formatted())
		.toolbar {
			ToolbarItem {
				ReadProgress(for: item) { progress in
					Gauge(value: progress) {
						Text("Progress")
							.font(.caption2)
							.foregroundStyle(.secondary)
					}
					.gaugeStyle(.accessoryLinearCapacity)
					.tint(progress == 1 ? .green : .accentColor)
					.animation(.bouncy, value: progress)
				}
			}
		}
	}
}

struct ContentView: View {
	@Environment(\.modelContext) private var modelContext
	@Query private var items: [Item]

	var body: some View {
		NavigationSplitView {
			List {
				ForEach(items) { item in
					NavigationLink {
						ItemView(item: item)
					} label: {
						ReadProgress(for: item) { progress in
							Gauge(value: progress) {
								Text("Progress")
									.font(.caption2)
									.foregroundStyle(.secondary)
							}
							.gaugeStyle(LilGaugeStyle())
							.tint(progress == 1 ? .green : .accentColor)
							.animation(.bouncy, value: progress)
						}
						Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
					}
				}
				.onDelete(perform: deleteItems)
			}
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					EditButton()
				}
				ToolbarItem {
					Button(action: addItem) {
						Label("Add Item", systemImage: "plus")
					}
				}
			}
			.onAppear {
				for _ in 0 ... 5 {
					addItem()
				}
			}
		} detail: {
			Text("Select an item")
		}
	}

	private func addItem() {
		withAnimation {
			let newItem = Item(timestamp: Date(), sections: Item.generateBody())
			modelContext.insert(newItem)
		}
	}

	private func deleteItems(offsets: IndexSet) {
		withAnimation {
			for index in offsets {
				modelContext.delete(items[index])
			}
		}
	}
}

#Preview {
	ContentView()
		.modelContainer(for: [Item.self, ReadStatusRecord.self], inMemory: true)
}
