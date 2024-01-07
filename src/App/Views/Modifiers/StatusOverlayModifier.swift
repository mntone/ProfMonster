import MonsterAnalyzerCore
import SwiftUI

struct StatusOverlayModifier: ViewModifier {
	let state: RequestState

	func body(content: Content) -> some View {
		content.overlay {
			switch state {
			case .loading:
				ProgressView()
			case let .failure(_, error):
				Text(error.label)
					.scenePadding()
			default:
				EmptyView()
			}
		}
	}
}
