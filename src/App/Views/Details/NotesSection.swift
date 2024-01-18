import SwiftUI

#if os(iOS)
import SwiftUIIntrospect
#endif

#if os(watchOS)

struct NotesSection: View {
	let note: String

	var body: some View {
		if !note.isEmpty {
			MASection("Notes") {
				Text(note)
			}
		}
	}
}

#else

struct NotesSection: View {
	let note: Binding<String>

#if !os(macOS)
	@Environment(\.horizontalLayoutMargin)
	private var horizontalLayoutMargin
#endif

	var body: some View {
#if os(macOS)
		MASection("Notes", background: .separatedInsetGrouped(rowInsets: nil)) {
			TextEditor(text: note)
				.font(.body)
				.backport.scrollContentBackground(.hidden, viewType: .textEditor)
		}
#else
		if #available(iOS 16.0, *) {
			MASection("Notes", background: .separatedInsetGrouped(rowInsets: nil)) {
				TextField(text: note, axis: .vertical) {
					Never?.none
				}
			}
		} else {
			MASection("Notes", background: .none(rowInsets: .zero)) {
				TextEditor(text: note)
					.clipShape(.rect(cornerRadius: MAFormMetrics.cornerRadius))
					.introspect(.textEditor, on: .iOS(.v15)) { (textView: UITextView) in
						// Disable scroll behavior.
						textView.isScrollEnabled = false

						// Set current context insets.
						textView.textContainerInset = UIEdgeInsets(top: MAFormMetrics.verticalRowInset,
																   left: horizontalLayoutMargin,
																   bottom: MAFormMetrics.verticalRowInset,
																   right: horizontalLayoutMargin)
					}
			}
		}
#endif
	}
}

#endif
