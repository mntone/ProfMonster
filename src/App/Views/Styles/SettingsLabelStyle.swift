import SwiftUI

@available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
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
			let iconSize = self.iconSize
			configuration.icon
				.font(.system(size: iconFontSize))
				.frame(width: iconSize, height: iconSize)
				.foregroundStyle(.white)
#if os(watchOS)
				.background(.accent.gradient, in: Circle())
#else
				.background(.accent.gradient, in: RoundedRectangle(cornerRadius: cornerRadius))
#endif
				//.backgroundStyle(scenePhase == .active ? .primary : .secondary)
#if os(macOS)
				.compositingGroup()
				.shadow(radius: 0.5, y: 0.5)
#endif
			configuration.title
				.multilineTextAlignment(.leading)
		}
	}

	private var iconFontSize: CGFloat {
#if os(macOS)
		switch sidebarRowSize {
		case .small:
			return 9.0
		case .large:
			return 21.0
		case .medium:
			fallthrough
		@unknown default:
			return 15.0
		}
#elseif os(watchOS)
		return 13.0
#else
		return 20.0
#endif
	}

	private var iconSize: CGFloat {
#if os(macOS)
		switch sidebarRowSize {
		case .small:
			return 14.0
		case .large:
			return 26.0
		case .medium:
			fallthrough
		@unknown default:
			return 20.0
		}
#elseif os(watchOS)
		return 16.0
#else
		return 30.0
#endif
	}

	private var cornerRadius: CGFloat {
#if os(macOS)
		switch sidebarRowSize {
		case .small:
			return 3.0
		case .large:
			return 6.0
		case .medium:
			fallthrough
		@unknown default:
			return 4.0
		}
#else
		return 7.0
#endif
	}
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
extension LabelStyle where Self == SettingsLabelStyle {
	static var settings: SettingsLabelStyle {
		Self()
	}
}

#if !os(macOS)

@available(iOS, introduced: 15.0, deprecated: 16.0, message: "Use SettingsLabelStyle instead")
@available(watchOS, introduced: 8.0, deprecated: 9.0, message: "Use SettingsLabelStyle instead")
@available(macOS, unavailable)
struct SettingsLabelStyleBackport: LabelStyle {
	@ViewBuilder
	func makeBody(configuration: Configuration) -> some View {
		HStack {
			let iconSize = self.iconSize
			configuration.icon
				.font(.system(size: iconFontSize))
				.frame(width: iconSize, height: iconSize)
				.foregroundStyle(.white)
#if os(watchOS)
				.background(.accent, in: Circle())
#else
				.background(.accent, in: RoundedRectangle(cornerRadius: cornerRadius))
#endif
			configuration.title
				.multilineTextAlignment(.leading)
		}
	}

	private var iconFontSize: CGFloat {
#if os(watchOS)
		return 13.0
#else
		return 20.0
#endif
	}

	private var iconSize: CGFloat {
#if os(watchOS)
		return 16.0
#else
		return 30.0
#endif
	}

#if os(iOS)
	private var cornerRadius: CGFloat {
		return 7.0
	}
#endif
}

@available(iOS, introduced: 15.0, deprecated: 16.0, message: "Use LabelStyle.settings instead")
@available(watchOS, introduced: 8.0, deprecated: 9.0, message: "Use LabelStyle.settings instead")
@available(macOS, unavailable)
extension LabelStyle where Self == SettingsLabelStyleBackport {
	static var settingsBackport: SettingsLabelStyleBackport {
		Self()
	}
}

#endif
