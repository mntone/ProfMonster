import SwiftUI

@available(macOS 13.0, *)
struct SettingsLabelStyle: LabelStyle {
	//	@Environment(\.scenePhase)
	//	private var scenePhase

#if os(macOS)
	@Environment(\.sidebarRowSize)
	private var sidebarRowSize
#endif

	@ViewBuilder
	func makeBody(configuration: Configuration) -> some View {
		HStack {
			if #available(iOS 16.0, watchOS 9.0, *) {
				let iconSize = self.iconSize
				configuration.icon
#if os(watchOS)
					.imageScale(.small)
#endif
					.frame(width: iconSize, height: iconSize)
#if os(watchOS)
					.padding(1.0)
#else
					.padding(2.0)
#endif
					.foregroundStyle(.white)
#if os(watchOS)
					.background(.accent.gradient, in: Circle())
#else
					.background(.accent.gradient, in: RoundedRectangle(cornerRadius: 4.0))
#endif
				//.backgroundStyle(scenePhase == .active ? .primary : .secondary)
			} else {
				let iconSize = self.iconSize
				configuration.icon
#if os(watchOS)
					.imageScale(.small)
#endif
					.frame(width: iconSize, height: iconSize)
					.padding(2.0)
					.foregroundStyle(.white)
#if os(watchOS)
					.background(.accent, in: Circle())
#else
					.background(.accent, in: RoundedRectangle(cornerRadius: 4.0))
#endif
			}
			configuration.title
				.multilineTextAlignment(.leading)
		}
	}

	private var iconSize: CGFloat {
#if os(macOS)
		switch sidebarRowSize {
		case .small:
			return 16.0
		case .large:
			return 24.0
		case .medium:
			fallthrough
		@unknown default:
			return 20.0
		}
#elseif os(watchOS)
		return 16.0
#else
		return 24.0
#endif
	}
}

@available(macOS 13.0, *)
extension LabelStyle where Self == SettingsLabelStyle {
	static var settings: SettingsLabelStyle {
		Self()
	}
}
