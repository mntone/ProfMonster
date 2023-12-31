import SwiftUI

#if canImport(AppKit)

@available(macOS 12.0, *)
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

@available(macOS 12.0, *)
extension Backport where Content: View {
	@ViewBuilder
	public func alternatingRowBackgrounds(_ behavior: AlternatingRowBackgroundBehaviorBackport = .enabled) -> some View {
		if #available(macOS 14.0, *) {
			content.alternatingRowBackgrounds(behavior.nativeValue)
		} else {
			content.listStyle(.inset(alternatesRowBackgrounds: behavior.backportValue))
		}
	}
}

#endif
