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
	let fractionLength: Int

	private var integerFont: Font {
		.system(size: signFontSize,
				weight: viewModel.signWeight,
				design: .rounded)
	}

	private var fractionFont: Font {
		.system(size: 0.666666 * signFontSize,
				weight: viewModel.signWeight,
				design: .rounded)
	}

	private var number: some View {
		let power = pow(10, Float(fractionLength))
		let frac = (power * viewModel.value.truncatingRemainder(dividingBy: 1)).rounded()
		if frac == 0 {
			return Text(Int(viewModel.value), format: .number).font(integerFont)
			+ Text(verbatim: "." + String(repeating: "0", count: fractionLength)).font(fractionFont)
		} else {
			return Text(Int(viewModel.value), format: .number).font(integerFont)
			+ (Text(verbatim: ".") + Text(frac, format: .number.precision(.integerLength(fractionLength)))).font(fractionFont)
		}
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			Label(viewModel.attack.label, systemImage: viewModel.attack.imageName)
				.foregroundStyle(viewModel.attack.color)
				.accessibilityLabel(viewModel.attack.accessibilityLabel)

			number
#if !os(macOS)
				.minimumScaleFactor(0.5)
#endif
		}
		.accessibilityElement(children: .combine)
	}
}

struct FixedWidthWeaknessSectionView: View {
	private static let maxItemWidth: CGFloat = 80

#if !os(watchOS)
	@ScaledMetric(relativeTo: .title2)
	private var signFontSize: CGFloat = 22
#endif

	let viewModel: WeaknessSectionViewModel
	let displayMode: WeaknessDisplayMode
	let headerHidden: Bool

	@State
	private var itemWidth: CGFloat?

	private func updateItemWidth(from containerSize: CGFloat) {
		itemWidth = min(Self.maxItemWidth, containerSize / CGFloat(viewModel.items.count))
	}

	var body: some View {
		VStack(alignment: .leading) {
			if !headerHidden {
				DetailItemHeader(header: viewModel.header)
			}

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
				case let .number(fractionLength):
					let fractionLengthInt = Int(fractionLength)
					DividedHStack(alignment: .firstTextBaseline, spacing: 0) {
						ForEach(viewModel.items) { item in
							FixedWidthWeaknessNumberItemView(viewModel: item,
															 signFontSize: signFontSize,
															 fractionLength: fractionLengthInt)
						}
						.padding(.horizontal, 8)
						.frame(minWidth: 0, idealWidth: itemWidth, maxWidth: Self.maxItemWidth, alignment: .leading)
					}
					.labelStyle(.titleOnly)
					.padding(.horizontal, -8)
				}
#endif
			}
		}
		.lineLimit(1)
		.fixedSize(horizontal: false, vertical: true)
	}
}

struct FixedWidthWeaknessView: View {
	let viewModel: WeaknessViewModel

	var body: some View {
		let headerHidden = viewModel.sections.count <= 1
		return ForEach(viewModel.sections) { section in
			FixedWidthWeaknessSectionView(viewModel: section,
										  displayMode: viewModel.displayMode,
										  headerHidden: headerHidden)
		}
	}
}

#Preview("Sign") {
	let viewModel = WeaknessViewModel("mock",
									  displayMode: .sign,
									  rawValue: MockDataSource.physiology1)
	return Form {
		FixedWidthWeaknessView(viewModel: viewModel)
	}
}

#Preview("Number") {
	let viewModel = WeaknessViewModel("mock",
									  displayMode: .number(fractionLength: 1),
									  rawValue: MockDataSource.physiology1)
	return Form {
		FixedWidthWeaknessView(viewModel: viewModel)
	}
}

#Preview("Number2") {
	let viewModel = WeaknessViewModel("mock",
									  displayMode: .number(fractionLength: 2),
									  rawValue: MockDataSource.physiology1)
	return Form {
		FixedWidthWeaknessView(viewModel: viewModel)
	}
}
