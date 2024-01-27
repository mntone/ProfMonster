import SwiftUI

#if os(iOS)
import enum MonsterAnalyzerCore.KeyboardDismissMode
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
	@AppStorage(settings: \.keyboardDismissMode)
	private var keyboardDismissMode: KeyboardDismissMode
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
#else
		MASection("Notes", background: MASectionBackgroundStyle.none) {
			MATextField(enableDoneButton: keyboardDismissMode == .button,
						text: note)
				.clipShape(.rect(cornerRadius: MAFormMetrics.cornerRadius))
		}
#endif
	}
}

#endif
