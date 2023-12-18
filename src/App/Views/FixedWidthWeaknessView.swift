import MonsterAnalyzerCore
import SwiftUI

struct FixedWidthWeaknessItemView: View {
	let viewModel: WeaknessItemViewModel

#if !os(watchOS)
	@Environment(\.legibilityWeight)
	private var legibilityWeight

	@ScaledMetric(relativeTo: .title3)
	private var signFontSize: CGFloat = 20
#endif

	var body: some View {
		VStack(spacing: 0) {
			Label {
				Text(viewModel.attackKey)
			} icon: {
				viewModel.attackIcon
			}
			.foregroundColor(viewModel.attackColor)

			Text(viewModel.signKey)
				.foregroundColor(viewModel.signColor)
#if os(watchOS)
				.font(.system(.body, design: .rounded))
#else
				.font(.system(size: signFontSize,
							  weight: legibilityWeight == .bold ? .bold : .semibold,
							  design: .rounded))
#endif
		}
	}
}

struct FixedWidthWeaknessView: View {
	private static let maxItemWidth: CGFloat = 80

	let viewModel: WeaknessSectionViewModel

	@State
	private var itemWidth: CGFloat?

	private func updateItemWidth(from containerSize: CGFloat) {
		itemWidth = min(Self.maxItemWidth, containerSize / CGFloat(viewModel.items.count))
	}

	var body: some View {
		ZStack(alignment: .topLeading) {
			GeometryReader { proxy in
				Color.clear
#if os(watchOS)
					.onAppear {
						updateItemWidth(from: proxy.size.width)
					}
#else
					.onChangeBackport(of: proxy.size.width, initial: true) { _, newValue in
						updateItemWidth(from: newValue)
					}
#endif
			}

			HStack(spacing: 0) {
#if os(watchOS)
				ForEach(viewModel.items) { item in
					FixedWidthWeaknessItemView(viewModel: item)
				}
				.frame(width: itemWidth)
#else
				ForEach(viewModel.items.dropLast()) { item in
					FixedWidthWeaknessItemView(viewModel: item)
				}
				.frame(minWidth: 0, idealWidth: itemWidth, maxWidth: Self.maxItemWidth)
				.background(alignment: .trailing) {
					Divider()
				}

				FixedWidthWeaknessItemView(viewModel: viewModel.items.last!)
					.frame(minWidth: 0, idealWidth: itemWidth, maxWidth: Self.maxItemWidth)
#endif
			}
		}
		.fixedSize(horizontal: false, vertical: true)
		.padding(.vertical, 4)
		.labelStyle(.iconOnly)
	}
}

#Preview {
	FixedWidthWeaknessView(viewModel: WeaknessViewModel(rawValue: MockDataSource.physiology1).sections[0])
}
