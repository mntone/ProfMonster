import SwiftUI
import SwiftUIIntrospect

@available(iOS 15.0, macOS 12.0, *)
@available(watchOS, unavailable)
extension Backport where Content: View {
	@ViewBuilder
	public func scrollContentBackground<SwiftUIViewType: IntrospectableViewType>(_ visibility: Visibility, viewType: SwiftUIViewType) -> some View {
		if #available(iOS 16.0, macOS 13.0, watchOS 9.0, *) {
			content.scrollContentBackground(.hidden)
		} else {
			if visibility == .hidden {
				switch viewType.self {
#if os(macOS)
				case is ListType:
					content.introspect(.list, on: .macOS(.v12)) { (tableView: NSTableView) in
						tableView.backgroundColor = .clear
					}
#endif
				case is TextEditorType:
#if os(macOS)
					content.introspect(.textEditor, on: .macOS(.v12)) { (textView: NSTextView) in
						textView.drawsBackground = false
					}
#else
					content.introspect(.textEditor, on: .iOS(.v15)) { (textView: UITextView) in
						textView.backgroundColor = nil
					}
#endif
				default:
					fatalError()
				}
			} else {
				content
			}
		}
	}
}
