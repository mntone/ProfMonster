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
	@FocusState
	private var isActive: Bool

	@Environment(\.horizontalLayoutMargin)
	private var horizontalLayoutMargin

	@Environment(\.settings)
	private var settings

	@ScaledMetric(relativeTo: .body)
	private var verticalPadding: CGFloat = 11.0
#endif

	var body: some View {
#if os(macOS)
		MASection("Notes", background: .separatedInsetGrouped) {
			TextEditor(text: note)
				.font(.body)
				.backport.scrollContentBackground(.hidden, viewType: .textEditor)
				.preferredVerticalPadding()
				.padding(.horizontal, 6.0)
		}
		.ignoreLayoutMargin()
#else
		if #available(iOS 16.0, *) {
			MASection("Notes", background: MASectionBackgroundStyle.none) {
				TextField(text: note, axis: .vertical) {
					Never?.none
				}
				.focused($isActive)
				.padding(EdgeInsets(top: verticalPadding,
									leading: horizontalLayoutMargin,
									bottom: verticalPadding,
									trailing: horizontalLayoutMargin))
				.background(.formItemBackground, in: .rect(cornerRadius: MAFormMetrics.cornerRadius))
				.toolbar {
					if settings?.keyboardDismissMode == .button {
						ToolbarItemGroup(placement: .keyboard) {
							Spacer(minLength: 0.0)
							Button("Done") {
								isActive = false
							}
							.font(.body.bold())
						}
					}
				}
			}
		} else {
			MASection("Notes", background: MASectionBackgroundStyle.none) {
				TextEditor(text: note)
					.focused($isActive)
					.clipShape(.rect(cornerRadius: MAFormMetrics.cornerRadius))
					.introspect(.textEditor, on: .iOS(.v15)) { (textView: UITextView) in
						// Disable scroll behavior.
						textView.isScrollEnabled = false

						// Set current context insets.
						textView.textContainerInset = UIEdgeInsets(top: verticalPadding,
																   left: horizontalLayoutMargin - 6.0,
																   bottom: verticalPadding,
																   right: horizontalLayoutMargin - 6.0)
					}
					.block { content in
						if settings?.keyboardDismissMode == .button {
							content.toolbar {
								ToolbarItemGroup(placement: .keyboard) {
									Spacer(minLength: 0.0)
									Button("Done") {
										isActive = false
									}
									.font(.body.bold())
								}
							}
						} else {
							content
						}
					}
			}
		}
#endif
	}
}

#endif
