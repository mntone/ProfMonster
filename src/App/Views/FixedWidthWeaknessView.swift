import MonsterAnalyzerCore
import SwiftUI

struct FixedWidthWeaknessItemView: View {
	private let viewModel: WeaknessItemViewModel

#if !os(watchOS)
	@Environment(\.legibilityWeight)
	private var legibilityWeight

	@ScaledMetric(relativeTo: .title3)
	private var signFontSize: CGFloat = 20
#endif

	init(_ viewModel: WeaknessItemViewModel) {
		self.viewModel = viewModel
	}

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
	private let viewModel: WeaknessViewModel

	@State
	private var itemWidth: CGFloat?

	init(_ viewModel: WeaknessViewModel) {
		self.viewModel = viewModel
	}

	var body: some View {
		ZStack {
			GeometryReader { proxy in
				Color.clear.onAppear {
					itemWidth = proxy.size.width / CGFloat(viewModel.items.count)
				}
			}

			HStack(spacing: 0) {
#if os(watchOS)
				ForEach(viewModel.items) { item in
					FixedWidthWeaknessItemView(item).frame(width: itemWidth)
				}
#else
				ForEach(viewModel.items.dropLast()) { item in
					FixedWidthWeaknessItemView(item).frame(width: itemWidth)
					Divider()
				}

				FixedWidthWeaknessItemView(viewModel.items.last!).frame(width: itemWidth)
#endif
			}
			.labelStyle(.iconOnly)
		}
		.padding(.vertical, 4)
	}
}

#Preview {
	FixedWidthWeaknessView(MHMockDataOffer.monster1.createWeakness())
}
