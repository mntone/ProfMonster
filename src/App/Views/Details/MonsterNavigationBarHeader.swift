import SwiftUI

#if os(iOS)

@available(macOS, unavailable)
@available(watchOS, unavailable)
struct MonsterNavigationBarHeader: View {
	let viewModel: MonsterViewModel

	@ScaledMetric(relativeTo: .headline)
	private var adjustedHeadline: CGFloat = 16

	@ScaledMetric(relativeTo: .subheadline)
	private var adjustedSubheadline: CGFloat = 14

	var body: some View {
		if let anotherName = viewModel.anotherName {
			VStack(spacing: 2) {
				Text(verbatim: viewModel.name)
					.font(.system(size: adjustedHeadline, weight: .semibold))

				Text(verbatim: anotherName)
					.font(.system(size: adjustedSubheadline, weight: .regular))
					.foregroundStyle(.secondary)
			}
			.accessibilityElement(children: .combine)
		} else {
			Text(verbatim: viewModel.name)
				.font(.headline)
		}
	}
}

@available(iOS 16.0, *)
@available(macOS, unavailable)
@available(watchOS, unavailable)
#Preview {
	let viewModel = MonsterViewModel(id: "gulu_qoo", for: "mockgame")!
	return NavigationStack {
		EmptyView().toolbar {
			ToolbarItem(placement: .principal) {
				MonsterNavigationBarHeader(viewModel: viewModel)
			}
		}
	}
}

#endif
