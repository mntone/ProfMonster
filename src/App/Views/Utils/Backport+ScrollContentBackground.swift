import SwiftUI
import SwiftUIIntrospect

@available(iOS 15.0, macOS 12.0, *)
@available(watchOS, unavailable)
extension Backport where Content: View {
	@ViewBuilder
	public func scrollContentBackground(_ visibility: Visibility) -> some View {
		if #available(iOS 16.0, macOS 13.0, *) {
			content.scrollContentBackground(.hidden)
		} else {
			if visibility == .hidden {
#if os(macOS)
				content.introspect(.textEditor, on: .macOS(.v12)) { (textView: NSTextView) in
					textView.drawsBackground = false
				}
#else
				content.introspect(.textEditor, on: .iOS(.v15)) { (textView: UITextView) in
					textView.backgroundColor = nil
				}
#endif
			} else {
				content
			}
		}
	}
}
