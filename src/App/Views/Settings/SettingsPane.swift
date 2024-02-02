import SwiftUI

enum SettingsPane: String, CaseIterable, Hashable, Identifiable {
	case display = "Display"
	case data = "Data"
	case developer = "Developer"
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
		case .developer:
			return "hammer.fill"
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
	var view: some View {
		switch self {
		case .display:
			DisplaySettingsPane()
		case .data:
			DataSettingsPane()
		case .developer:
			DeveloperSettingsPane()
		case .app:
			AppSettingsPane()
		}
	}
}
