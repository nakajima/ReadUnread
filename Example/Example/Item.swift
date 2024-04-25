//
//  Item.swift
//  Example
//
//  Created by Pat Nakajima on 4/25/24.
//

import Foundation
import ReadUnread
import SwiftData

@Model
final class Item {
	var timestamp: Date
	var sections: [String] = []

	init(timestamp: Date, sections: [String]) {
		self.timestamp = timestamp
		self.sections = sections
	}

	static func generateBody() -> [String] {
		(0 ... Int.random(in: 20 ... 50)).map { _ in generateLoremIpsum(wordCount: Int.random(in: 20 ... 30)) }
	}

	static func generateLoremIpsum(wordCount: Int = 20) -> String {
		let loremIpsumWords = [
			"lorem", "ipsum", "dolor", "sit", "amet", "consectetur",
			"adipiscing", "elit", "sed", "do", "eiusmod", "tempor",
			"incididunt", "ut", "labore", "et", "dolore", "magna",
			"aliqua", "ut", "enim", "ad", "minim", "veniam",
		]

		var result = ""
		for _ in 0 ..< wordCount {
			if let randomWord = loremIpsumWords.randomElement() {
				result += randomWord + " "
			}
		}

		return result.trimmingCharacters(in: .whitespaces).capitalized
	}
}

extension Item: ReadUnreadable {
	var readableID: String { sections.first! }
	var readableSectionCount: Int { sections.count }
}
