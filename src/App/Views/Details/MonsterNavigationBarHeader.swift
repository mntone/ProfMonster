import SwiftUI

#if os(iOS)

@available(macOS, unavailable)
@available(watchOS, unavailable)
struct MonsterNavigationBarHeader: View {
	let viewModel: MonsterViewModel

	@Environment(\.verticalSizeClass)
	private var verticalSizeClass

	@ScaledMetric(relativeTo: .headline)
	private var adjustedHeadline: CGFloat = 16

	@ScaledMetric(relativeTo: .subheadline)
	private var adjustedSubheadline: CGFloat = 14

	var body: some View {
		if let name = viewModel.name {
			if let anotherName = viewModel.anotherName,
			   verticalSizeClass != .compact {
				VStack(spacing: 2) {
					Text(name)
						.font(.system(size: adjustedHeadline, weight: .semibold))

					Text(anotherName)
						.font(.system(size: adjustedSubheadline, weight: .regular))
						.foregroundStyle(.secondary)
				}
				.accessibilityElement(children: .combine)
			} else {
				Text(name)
					.font(.headline)
			}
		}
	}
}

@available(iOS 16.0, *)
@available(macOS, unavailable)
@available(watchOS, unavailable)
#Preview {
	let viewModel = MonsterViewModel()
	viewModel.set(id: "mockgame:gulu_qoo")
	return NavigationStack {
		EmptyView().toolbar {
			ToolbarItem(placement: .principal) {
				MonsterNavigationBarHeader(viewModel: viewModel)
			}
		}
	}
}

#endif
