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

private struct FixedWidthWeaknessSignItemView: View {
	let viewModel: WeaknessItemViewModel

#if !os(watchOS)
	let signFontSize: CGFloat
#endif

	var body: some View {
		VStack(spacing: 0) {
			Label(viewModel.attack.label, systemImage: viewModel.attack.imageName)
				.foregroundStyle(viewModel.attack.color)
				.accessibilityLabel(viewModel.attack.accessibilityLabel)

			Text(viewModel.effective.label)
				.foregroundStyle(viewModel.signColor)
#if os(watchOS)
				.font(.systemBackport(.body,
									  design: .rounded,
									  weight: viewModel.signWeight).leading(.tight))
#else
				.font(.system(size: signFontSize,
							  weight: viewModel.signWeight,
							  design: .rounded))
#endif
#if !os(macOS)
				.minimumScaleFactor(0.5)
#endif
				.accessibilityLabel(viewModel.effective.accessibilityLabel)
		}
		.accessibilityElement(children: .combine)
	}
}

@available(watchOS, unavailable)
private struct FixedWidthWeaknessNumberItemView: View {
	let viewModel: WeaknessItemViewModel
	let signFontSize: CGFloat

	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			Label(viewModel.attack.label, systemImage: viewModel.attack.imageName)
				.foregroundStyle(viewModel.attack.color)
				.accessibilityLabel(viewModel.attack.accessibilityLabel)

			Text(viewModel.value, format: .number.precision(.fractionLength(1)))
				.font(.system(size: signFontSize,
							  weight: viewModel.signWeight,
							  design: .rounded))
#if !os(macOS)
				.minimumScaleFactor(0.5)
#endif
		}
		.accessibilityElement(children: .combine)
	}
}

struct FixedWidthWeaknessView: View {
	private static let maxItemWidth: CGFloat = 80

#if !os(watchOS)
	@ScaledMetric(relativeTo: .title3)
	private var signFontSize: CGFloat = 20
#endif

	let displayMode: WeaknessDisplayMode
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

#if os(watchOS)
			HStack(alignment: .firstTextBaseline, spacing: 0) {
				ForEach(viewModel.items) { item in
					FixedWidthWeaknessSignItemView(viewModel: item)
				}
				.frame(width: itemWidth)
			}
			.labelStyle(.iconOnly)
#else
			switch displayMode {
			case .none:
				EmptyView()
			case .sign:
				DividedHStack(alignment: .firstTextBaseline, spacing: 0) {
					ForEach(viewModel.items) { item in
						FixedWidthWeaknessSignItemView(viewModel: item, signFontSize: signFontSize)
					}
					.frame(minWidth: 0, idealWidth: itemWidth, maxWidth: Self.maxItemWidth)
				}
				.labelStyle(.iconOnly)
			case .number:
				DividedHStack(alignment: .firstTextBaseline, spacing: 0) {
					ForEach(viewModel.items) { item in
						FixedWidthWeaknessNumberItemView(viewModel: item, signFontSize: signFontSize)
					}
					.padding(.horizontal, 8)
					.frame(minWidth: 0, idealWidth: itemWidth, maxWidth: Self.maxItemWidth, alignment: .leading)
				}
				.labelStyle(.titleOnly)
				.padding(.horizontal, -8)
			}
#endif
		}
		.lineLimit(1)
		.fixedSize(horizontal: false, vertical: true)
		.padding(.vertical, 4)
	}
}

#Preview("Sign") {
	FixedWidthWeaknessView(displayMode: .sign,
						   viewModel: WeaknessViewModel(rawValue: MockDataSource.physiology1).sections[0])
}

#Preview("Number") {
	FixedWidthWeaknessView(displayMode: .number,
						   viewModel: WeaknessViewModel(rawValue: MockDataSource.physiology1).sections[0])
}
