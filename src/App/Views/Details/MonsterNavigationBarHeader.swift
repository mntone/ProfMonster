#if os(iOS)

import SwiftUI

@available(macOS, unavailable)
@available(watchOS, unavailable)
struct MonsterNavigationBarHeader: View {
	let name: String
	let anotherName: String

	@Environment(\.verticalSizeClass)
	private var verticalSizeClass

	@ScaledMetric(relativeTo: .headline)
	private var adjustedHeadline: CGFloat = 16

	@ScaledMetric(relativeTo: .subheadline)
	private var adjustedSubheadline: CGFloat = 14

	var body: some View {
		if verticalSizeClass != .compact {
			let content = VStack(spacing: 2) {
				Text(name)
					.font(.system(size: adjustedHeadline, weight: .semibold))

				Text(anotherName)
					.font(.system(size: adjustedSubheadline, weight: .regular))
					.foregroundStyle(.secondary)
			}
			.accessibilityElement(children: .combine)

			if #available(iOS 16.0, *) {
				content
			} else if UIDevice.current.userInterfaceIdiom == .pad {
				// Fix title are cut off on iPadOS 15.
				content.frame(maxWidth: 240.0)
			} else {
				content
			}
		}
	}
}

@available(iOS 16.0, *)
@available(macOS, unavailable)
@available(watchOS, unavailable)
#Preview {
	NavigationStack {
		EmptyView().toolbar {
			ToolbarItem(placement: .principal) {
				MonsterNavigationBarHeader(name: "Powered Lime Gulu Qoo",
										   anotherName: "Loudest Piyopiyo")
			}
		}
	}
}

#endif
