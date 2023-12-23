import SwiftUI

enum SettingsPane: String, CaseIterable, Hashable, Identifiable {
	case display = "Display"
	case data = "Data"
	case app = "About App"

	var id: String {
		rawValue
	}

	var systemImage: String {
		switch self {
		case .display:
			return "character"
		case .data:
			return "doc.text"
		case .app:
#if os(watchOS)
			return "info"
#else
			return "info.circle"
#endif
		}
	}

	var label: Label<Text, Image> {
		Label(LocalizedStringKey(rawValue),
			  systemImage: systemImage)
	}

	@ViewBuilder
	func view(_ viewModel: SettingsViewModel) -> some View {
		switch self {
		case .display:
			DisplaySettingsPane(viewModel: viewModel)
		case .data:
			DataSettingsPane(viewModel: viewModel)
		case .app:
			AppSettingsPane()
		}
	}
}
