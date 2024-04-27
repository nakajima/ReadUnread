//
//  ViewDidAppearModifier.swift
//
//
//  Created by Pat Nakajima on 4/27/24.
//

import SwiftUI
import UIKit

class ViewDidAppearController: UIViewController {
	typealias Callback = () -> Void

	var didAppear: Callback?
	var didDisappear: Callback?

	init(
		didAppear: Callback? = nil,
		didDisappear: Callback? = nil
	) {
		self.didAppear = didAppear
		self.didDisappear = didDisappear

		super.init(nibName: nil, bundle: nil)
	}

	override func viewDidAppear(_: Bool) {
		didAppear?()
	}

	override func viewWillDisappear(_: Bool) {
		didDisappear?()
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

struct ViewAppearanceRepresentable: UIViewControllerRepresentable {
	var didAppear: ViewDidAppearController.Callback?
	var didDisppear: ViewDidAppearController.Callback?

	struct Coordinator {
		let controller: ViewDidAppearController

		init(
			didAppear: ViewDidAppearController.Callback?,
			didDisappear: ViewDidAppearController.Callback?
		) {
			self.controller = ViewDidAppearController(didAppear: didAppear, didDisappear: didDisappear)
		}
	}

	func makeCoordinator() -> Coordinator {
		Coordinator(didAppear: didAppear, didDisappear: didDisppear)
	}

	func makeUIViewController(context: Context) -> ViewDidAppearController {
		context.coordinator.controller
	}

	func updateUIViewController(_: ViewDidAppearController, context _: Context) {}
}

struct ViewDidAppearModifier: ViewModifier {
	var callback: ViewDidAppearController.Callback

	func body(content: Content) -> some View {
		content
			.overlay(alignment: .bottom) {
				ViewAppearanceRepresentable(didAppear: callback)
					.frame(height: 1)
			}
	}
}

struct ViewDidDisappearModifier: ViewModifier {
	var callback: ViewDidAppearController.Callback

	func body(content: Content) -> some View {
		content
			.overlay(alignment: .bottom) {
				ViewAppearanceRepresentable(didDisppear: callback)
					.frame(height: 1)
			}
	}
}

extension View {
	func viewDidAppear(perform: @escaping ViewDidAppearController.Callback) -> some View {
		modifier(ViewDidAppearModifier(callback: perform))
	}

	func viewDidDisappear(perform: @escaping ViewDidAppearController.Callback) -> some View {
		modifier(ViewDidDisappearModifier(callback: perform))
	}
}

#if DEBUG
	struct ViewDidAppearPreviewView: View {
		@State var visible: Set<Int> = [2]

		var body: some View {
			ScrollView {
				LazyVStack {
					ForEach(0 ..< 200, id: \.self) { i in
						HStack {
							Text("Section")
								.foregroundStyle(.secondary)
							Spacer()
							Text(i, format: .number)
								.bold()
						}
						.font(.title)
						.padding()
						.overlay {
							LazyVStack {
								Rectangle()
									.fill(.clear)
									.viewDidAppear {
										visible.insert(i)
									}
									.viewDidDisappear {
										visible.remove(i)
									}
							}
						}
						Divider()
					}
				}
			}
			.safeAreaInset(edge: .bottom) {
				if !visible.isEmpty {
					Text("Visible: \(visible.sorted().map(\.description).joined(separator: ", "))")
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
		ViewDidAppearPreviewView()
	}
#endif
