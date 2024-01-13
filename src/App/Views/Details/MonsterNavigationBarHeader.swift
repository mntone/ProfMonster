#if os(iOS)

import SwiftUI

@available(macOS, unavailable)
@available(watchOS, unavailable)
struct MonsterNavigationBarHeader: View {
	let name: String
	let anotherName: String?

	@Environment(\.settings)
	private var settings

	@ScaledMetric(relativeTo: .headline)
	private var adjustedHeadline: CGFloat = 16

	@ScaledMetric(relativeTo: .subheadline)
	private var adjustedSubheadline: CGFloat = 14

	var body: some View {
		if settings?.showTitle ?? true,
		   let anotherName {
			NavigationBarTitleViewSupport {
				VStack(spacing: 2) {
					Text(name)
						.font(.system(size: adjustedHeadline, weight: .semibold))

					Text(anotherName)
						.font(.system(size: adjustedSubheadline, weight: .regular))
						.foregroundStyle(.secondary)
				}
				.lineLimit(1)
				.accessibilityElement(children: .combine)
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
