import SwiftUI

private struct _NavigationBarAdaptiveStack<Content>: View where Content: View {
	@Environment(\.narrowNavigationBar)
	private var narrowNavigationBar

	@State
	private(set) var spacing: CGFloat

	@ViewBuilder
	let content: () -> Content

	var body: some View {
		if narrowNavigationBar {
			HStack(alignment: .firstTextBaseline, spacing: 8.0, content: content)
		} else {
			VStack(spacing: spacing, content: content)
		}
	}
}

@available(macOS, unavailable)
@available(watchOS, unavailable)
struct MonsterNavigationBarHeader: View {
	let name: String
	let anotherName: String?

	@Environment(\.dynamicTypeSize)
	private var dynamicTypeSize

	var body: some View {
		if let anotherName {
			_NavigationBarAdaptiveStack(spacing: spacing) {
				Text(name)
					.font(.headline)

				Text(anotherName)
					.font(.subheadline)
					.foregroundStyle(.secondary)
			}
			.lineLimit(1)
			.accessibilityElement(children: .combine)
		}
	}

	private var spacing: CGFloat {
		switch dynamicTypeSize {
		case .xxLarge:
			0.0
		default:
			1.0
		}
	}
}

@available(iOS 16.0, *)
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
