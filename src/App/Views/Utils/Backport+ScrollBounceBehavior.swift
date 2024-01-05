import SwiftUI

#if !os(watchOS)
import SwiftUIIntrospect
#endif

public enum ScrollBounceBehaviorBackport {
	case automatic
	case always
	case basedOnSize

	@available(iOS 16.4, macOS 13.3, watchOS 9.4, *)
	var nativeValue: ScrollBounceBehavior {
		switch self {
		case .automatic:
			return .automatic
		case .always:
			return .always
		case .basedOnSize:
			return .basedOnSize
		}
	}
}

extension Backport where Content: View {
	@ViewBuilder
	public func scrollBounceBehavior(_ behavior: ScrollBounceBehaviorBackport, axes: Axis.Set = [.vertical]) -> some View {
		if #available(iOS 16.4, macOS 13.3, watchOS 9.4, *) {
			content.scrollBounceBehavior(.basedOnSize, axes: axes)
		} else {
#if os(iOS)
			switch axes {
			case [.vertical, .horizontal]:
				switch behavior {
				case .automatic:
					content
				case .always:
					content.introspect(.scrollView, on: .iOS(.v15, .v16)) { (scrollView: UIScrollView) in
						scrollView.alwaysBounceVertical = true
						scrollView.alwaysBounceHorizontal = true
					}
				case .basedOnSize:
					content.introspect(.scrollView, on: .iOS(.v15, .v16)) { (scrollView: UIScrollView) in
						scrollView.alwaysBounceVertical = false
						scrollView.alwaysBounceHorizontal = false
					}
				}
			case .vertical:
				switch behavior {
				case .automatic:
					content
				case .always:
					content.introspect(.scrollView, on: .iOS(.v15, .v16)) { (scrollView: UIScrollView) in
						scrollView.alwaysBounceVertical = true
					}
				case .basedOnSize:
					content.introspect(.scrollView, on: .iOS(.v15, .v16)) { (scrollView: UIScrollView) in
						scrollView.alwaysBounceVertical = false
					}
				}
			case .horizontal:
				switch behavior {
				case .automatic:
					content
				case .always:
					content.introspect(.scrollView, on: .iOS(.v15, .v16)) { (scrollView: UIScrollView) in
						scrollView.alwaysBounceHorizontal = true
					}
				case .basedOnSize:
					content.introspect(.scrollView, on: .iOS(.v15, .v16)) { (scrollView: UIScrollView) in
						scrollView.alwaysBounceHorizontal = false
					}
				}
			default:
				content
			}
#else
			content
#endif
		}
	}
}
