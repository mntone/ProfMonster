import SwiftUI

@available(iOS, unavailable)
@available(macOS 12.0, *)
@available(watchOS, unavailable)
public enum AlternatingRowBackgroundBehaviorBackport {
	case automatic
	case enabled
	case disabled

	@available(macOS 14.0, *)
	var nativeValue: AlternatingRowBackgroundBehavior {
		switch self {
		case .automatic:
			return .automatic
		case .enabled:
			return .enabled
		case .disabled:
			return .disabled
		}
	}

	@available(macOS, deprecated: 14.0)
	var backportValue: Bool {
		switch self {
		case .automatic:
			return false
		case .enabled:
			return true
		case .disabled:
			return false
		}
	}
}

@available(iOS, unavailable)
@available(macOS 12.0, *)
@available(watchOS, unavailable)
extension Backport where Content: View {
	@ViewBuilder
	public func listStyleInsetAlternatingRowBackgrounds(_ behavior: AlternatingRowBackgroundBehaviorBackport = .enabled) -> some View {
		if #available(macOS 14.0, *) {
			content.listStyle(.inset).alternatingRowBackgrounds(behavior.nativeValue)
		} else {
			content.listStyle(.inset(alternatesRowBackgrounds: behavior.backportValue))
		}
	}
}
