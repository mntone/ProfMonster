import Foundation
import SwiftUI

public struct BottomCircularButtonStyle: ButtonStyle {
	public let alignment: HorizontalAlignment

	private struct _Button: View {
		let alignment: HorizontalAlignment
		let configuration: ButtonStyleConfiguration

		@Environment(\.imageScale)
		private var imageScale

		@Environment(\.watchMetrics)
		private var watchMetrics

		var body: some View {
			configuration.label
				.labelStyle(.iconOnly)
				.frame(width: watchMetrics.topCircularButtonLength,
					   height: watchMetrics.topCircularButtonLength)
				.background(Color(white: 70.0 / 255))
				.clipShape(.circle)
				.padding(getButtonPadding())
				.contentShape(.rect)
				.opacity(configuration.isPressed ? 0.6 : 1.0)
				.scaleEffect(configuration.isPressed ? 0.75 : 1.0)
		}

		private func getButtonPadding() -> EdgeInsets {
			let ref = watchMetrics.preferredSafeAreaInsets
			switch watchMetrics.bezel {
			case .square:
				switch alignment {
				case .leading:
					return EdgeInsets(top: 6, leading: 2, bottom: ref.bottom, trailing: 8)
				case .center:
					return EdgeInsets(top: 6, leading: 5, bottom: ref.bottom, trailing: 5)
				case .trailing:
					return EdgeInsets(top: 6, leading: 8, bottom: ref.bottom, trailing: 2)
				default:
					fatalError()
				}
			case .round:
				switch alignment {
				case .leading:
					return EdgeInsets(top: ref.leading, leading: 0, bottom: ref.bottom, trailing: 6)
				case .center:
					return EdgeInsets(top: min(ref.leading, ref.trailing), leading: 6, bottom: ref.bottom, trailing: 6)
				case .trailing:
					return EdgeInsets(top: ref.trailing, leading: 6, bottom: ref.bottom, trailing: 0)
				default:
					fatalError()
				}
			}
		}
	}

	public func makeBody(configuration: Configuration) -> some View {
		_Button(alignment: alignment, configuration: configuration)
	}
}

public extension ButtonStyle where Self == BottomCircularButtonStyle {
	static func bottomCircular(_ alignment: HorizontalAlignment) -> BottomCircularButtonStyle {
		BottomCircularButtonStyle(alignment: alignment)
	}
}

struct BottomCircularButtonSafeAreaInsetAdjustModifier: ViewModifier {
	private struct _AdjustView: View {
		@Environment(\.watchMetrics)
		private var watchMetrics

		var body: some View {
			Color.clear.frame(height: watchMetrics.topCircularButtonLength + watchMetrics.preferredSafeAreaInsets.bottom)
		}
	}

	func body(content: Content) -> some View {
		content.safeAreaInset(edge: .bottom) {
			_AdjustView()
		}
	}
}

extension View {
	@ViewBuilder
	func bottomCircularButtonSafeAreaInsetAdjust() -> ModifiedContent<Self, BottomCircularButtonSafeAreaInsetAdjustModifier> {
		modifier(BottomCircularButtonSafeAreaInsetAdjustModifier())
	}
}

#Preview {
	NavigationView {
		ZStack(alignment: .bottomLeading) {
			List {
				Text(verbatim: "Test1")
				Text(verbatim: "Test2")
				Text(verbatim: "Test3")
				Text(verbatim: "Test4")
				Text(verbatim: "Test5")
				Text(verbatim: "Test6")
				Text(verbatim: "Test7")
			}.bottomCircularButtonSafeAreaInsetAdjust()

			Button(action: {}) {
				Image(systemName: "gearshape.fill")
			}.buttonStyle(.bottomCircular(.leading))
		}.ignoresSafeArea(.all, edges: .bottom)
	}.environment(\.watchMetrics, WatchUtil.getMetrics())
}
