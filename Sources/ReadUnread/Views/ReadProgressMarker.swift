//
//  ReadProgressMarker.swift
//
//
//  Created by Pat Nakajima on 4/27/24.
//

import SwiftUI

public struct ReadProgressMarker: View {
	var id: Int

	public init(id: Int) {
		self.id = id
	}

	public var body: some View {
		Rectangle()
			.fill(.clear)
			.frame(height: 1)
			.id(id)
	}
}

#if DEBUG
#Preview {
	ReadProgressMarker(id: 1)
}
#endif
