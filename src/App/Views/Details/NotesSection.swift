import SwiftUI

#if os(iOS)
import enum MonsterAnalyzerCore.KeyboardDismissMode
import enum MonsterAnalyzerCore.NavigationBarHideMode
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

#if os(iOS)
	@AppStorage(settings: \.keyboardDismissMode)
	private var keyboardDismissMode: KeyboardDismissMode

	@AppStorage(settings: \.navigationBarHideMode)
	private var navigationBarHideMode: NavigationBarHideMode

	@Environment(\.verticalSizeClass)
	private var verticalSizeClass

	@State
	private var isEditing: Bool = false
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
		let section = MASection("Notes", background: MASectionBackgroundStyle.none) {
			MATextField(enableDoneButton: keyboardDismissMode == .button,
						text: note,
						isEditing: $isEditing)
				.clipShape(.rect(cornerRadius: MAFormMetrics.cornerRadius))
		}

		if UIDevice.current.systemName == "iOS" {
			if #available(iOS 16.0, *) {
				section.toolbar(navigatinBarHidden ? .hidden : .visible, for: .navigationBar)
			} else {
				section.navigationBarHidden(navigatinBarHidden)
			}
		} else {
			section
		}
#endif
	}

#if os(iOS)
	private var navigatinBarHidden: Bool {
		switch navigationBarHideMode {
		case .nothing:
			false
		case .editingLandscape:
			if verticalSizeClass == .regular {
				false
			} else {
				isEditing
			}
		case .editing:
			isEditing
		}
	}
#endif
}

#endif
