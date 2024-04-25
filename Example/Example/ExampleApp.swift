//
//  ExampleApp.swift
//  Example
//
//  Created by Pat Nakajima on 4/25/24.
//

import ReadUnread
import SwiftData
import SwiftUI

@main
struct ExampleApp: App {
	var sharedModelContainer: ModelContainer = {
		let schema = Schema([
			Item.self,
			ReadStatusRecord.self,
		])
		let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

		do {
			return try ModelContainer(for: schema, configurations: [modelConfiguration])
		} catch {
			fatalError("Could not create ModelContainer: \(error)")
		}
	}()

	var body: some Scene {
		WindowGroup {
			ContentView()
		}
		.modelContainer(sharedModelContainer)
	}
}
