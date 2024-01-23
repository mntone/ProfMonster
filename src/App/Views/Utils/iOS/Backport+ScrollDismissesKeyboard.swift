import SwiftUI
import SwiftUIIntrospect

@available(iOS 14.0, *)
@available(tvOS, unavailable)
@available(visionOS, unavailable)
public enum ScrollDismissesKeyboardModeBackport {
	case automatic
	case immediately
	case interactively
	case never

	@available(iOS 16.0, *)
	var nativeValue: ScrollDismissesKeyboardMode {
		switch self {
		case .automatic:
			return .automatic
		case .immediately:
			return .immediately
		case .interactively:
			return .interactively
		case .never:
			return .never
		}
	}

	@available(iOS, deprecated: 16.0)
	var backportValue: UIScrollView.KeyboardDismissMode {
		switch self {
		case .automatic:
			return .none
		case .immediately:
			return .onDrag
		case .interactively:
			return .interactive
		case .never:
			return .none
		}
	}
}

@available(iOS 14.0, *)
@available(tvOS, unavailable)
@available(visionOS, unavailable)
extension Backport where Content: View {
	@ViewBuilder
	public func scrollDismissesKeyboard(_ mode: ScrollDismissesKeyboardModeBackport) -> some View {
		if #available(iOS 16.0, *) {
			content.scrollDismissesKeyboard(mode.nativeValue)
		} else {
			content.introspect(.list(style: .inset), on: .iOS(.v14, .v15)) { tableView in
				tableView.keyboardDismissMode = mode.backportValue
			}
		}
	}

	@ViewBuilder
	public func scrollViewScrollDismissesKeyboard(_ mode: ScrollDismissesKeyboardModeBackport) -> some View {
		if #available(iOS 16.0, *) {
			content.scrollDismissesKeyboard(mode.nativeValue)
		} else {
			content.introspect(.scrollView, on: .iOS(.v14, .v15)) { scrollView in
				scrollView.keyboardDismissMode = mode.backportValue
			}
		}
	}
}
