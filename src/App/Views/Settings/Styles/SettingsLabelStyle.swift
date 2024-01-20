import SwiftUI

@available(macOS 13.0, *)
private protocol SettingsLabelMetrics {
#if os(macOS)
	var sidebarRowSize: SidebarRowSize { get }
#endif
}

@available(macOS 13.0, *)
extension SettingsLabelMetrics {
	fileprivate var iconFontSize: CGFloat {
#if os(macOS)
		switch sidebarRowSize {
		case .small:
			return 8.0
		case .large:
			return 20.0
		case .medium:
			fallthrough
		@unknown default:
			return 14.0
		}
#elseif os(watchOS)
		return 11.0
#else
		return 19.0
#endif
	}

	fileprivate var iconSize: CGFloat {
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

	fileprivate var cornerRadius: CGFloat {
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
struct SettingsLabelStyle: LabelStyle, SettingsLabelMetrics {
#if os(macOS)
	@Environment(\.sidebarRowSize)
	fileprivate var sidebarRowSize
#endif

	@ViewBuilder
	func makeBody(configuration: Configuration) -> some View {
		HStack(spacing: spacing) {
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
				.environment(\.legibilityWeight, .regular)
#if os(macOS)
				.compositingGroup()
				.shadow(radius: 0.5, y: 0.5)
#endif
			configuration.title
				.multilineTextAlignment(.leading)
#if os(iOS)
				.differentialPreferredVerticalPadding()
#endif
		}
	}

	private var spacing: CGFloat {
#if os(macOS)
		switch sidebarRowSize {
		case .large:
			return 9.0
		case .small, .medium:
			fallthrough
		@unknown default:
			return 7.0
		}
#elseif os(watchOS)
		return 9.0
#else
		return 13.0
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
struct SettingsLabelStyleBackport: LabelStyle, SettingsLabelMetrics {
#if os(watchOS)
	@Environment(\.watchMetrics)
	private var watchMetrics
#endif

	@ViewBuilder
	func makeBody(configuration: Configuration) -> some View {
		HStack(spacing: spacing) {
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
				.environment(\.legibilityWeight, .regular)
			configuration.title
				.multilineTextAlignment(.leading)
#if os(iOS)
				.insetGroupedDifferentialPreferredVerticalPaddingBackport3()
#endif
		}
	}

	private var spacing: CGFloat {
#if os(watchOS)
		if watchMetrics.device == .case38 {
			return 8.0
		} else {
			return 9.0
		}
#else
		return 15.0
#endif
	}
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
