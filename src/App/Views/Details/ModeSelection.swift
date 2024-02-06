import SwiftUI

struct ModeSelection: View {
	let isBackgroundShown: Bool

	@ObservedObject
	private(set) var viewModel: MonsterViewModel

	@Environment(\.verticalSizeClass)
	private var verticalSizeClass

	var body: some View {
		Group {
			if viewModel.items.count > 1 {
				Picker("Mode", selection: $viewModel.selectedItem) {
					ForEach(viewModel.items) { item in
						Text(item.mode.label(.medium))
							.accessibilityLabel(item.mode.label(.long))
							.tag(item as MonsterDataViewModel?)
					}
				}
				.pickerStyle(.segmented)
				.layoutMargin()
				.frame(minHeight: verticalSizeClass == .compact ? 36.0 : 40.0)
			} else {
				Color.clear.frame(maxWidth: .infinity, maxHeight: 0.0)
			}
		}
		.background(Material.bar.opacity(isBackgroundShown ? 1.0 : 0.0),
					ignoresSafeAreaEdges: [.top, .horizontal])
		.overlay(alignment: .bottom) {
			ChromeShadow()
				.opacity(isBackgroundShown ? 1.0 : 0.0)
				.ignoresSafeArea(.container, edges: .horizontal)
		}
		.animation(.linear(duration: 0.05), value: isBackgroundShown)
	}
}
