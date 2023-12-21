import MonsterAnalyzerCore
import SwiftUI

extension Font {
	public static func systemBackport(_ style: Font.TextStyle, design: Font.Design? = nil, weight: Font.Weight? = nil) -> Font {
		if #available(iOS 16.0, macOS 13.0, watchOS 9.0, *) {
			system(style, design: design, weight: weight)
		} else {
			system(style, design: design ?? .default).weight(weight ?? .regular)
		}
	}
}

struct FixedWidthWeaknessItemView: View {
	let viewModel: WeaknessItemViewModel

#if !os(watchOS)
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

			Text(viewModel.effective.rawValue)
				.foregroundColor(viewModel.signColor)
#if os(watchOS)
				.font(.systemBackport(.body,
									  design: .rounded,
									  weight: viewModel.signWeight))
#else
				.font(.system(size: signFontSize,
							  weight: viewModel.signWeight,
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

			HStack(alignment: .lastTextBaseline, spacing: 0) {
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
