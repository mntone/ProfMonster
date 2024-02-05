import MonsterAnalyzerCore
import SwiftUI

struct PhysiologyHeaderHeightPreferenceKey: PreferenceKey {
	static var defaultValue: [PhysiologyViewModel.ID: CGFloat] = [:]

	static func reduce(value: inout [PhysiologyViewModel.ID: CGFloat], nextValue: () -> [PhysiologyViewModel.ID: CGFloat]) {
		value.merge(nextValue()) { cur, next in next }
	}
}

private struct _ScrollablePhysiologyRowHeaderView: View {
	let viewModel: [PhysiologyColumnViewModel]
	let itemWidth: CGFloat
	let spacing: CGFloat

	var body: some View {
		HStack(spacing: spacing) {
			ForEach(viewModel) { item in
				item.attack.image
#if !os(watchOS)
					.help(item.attack.label(.long))
#endif
					.foregroundStyle(item.attack.color)
			}
			.frame(maxWidth: itemWidth)

			Image(.stun)
#if !os(watchOS)
				.help("Stun")
#endif
				.foregroundStyle(.thunder)
				.frame(width: itemWidth)
		}
		.padding(PhysiologyViewMetrics.padding.setting(leading: spacing))
		.accessibilityHidden(true)
	}
}

private struct _ScrollablePhysiologyHeaderView: View {
	let viewModel: PhysiologyViewModel

	var body: some View {
		Text(viewModel.header)
			.foregroundStyle(viewModel.hierarchical)
			.background(GeometryReader { proxy in
				Color.clear.preference(key: PhysiologyHeaderHeightPreferenceKey.self,
									   value: [viewModel.id: proxy.size.height])
			})
	}
}

private struct _ScrollablePhysiologyContentView: View {
	let viewModel: PhysiologyViewModel
	let itemWidth: CGFloat
	let spacing: CGFloat

	var body: some View {
		HStack(spacing: spacing) {
			ForEach(viewModel.values) { item in
				let text = Text(item.value, format: .number)
				text
					.block { content in
						if #available(iOS 17.0, watchOS 10.0, *) {
							content.foregroundStyle(item.foregroundStyle)
						} else {
							content.foregroundStyle(AnyShapeStyle(item.foregroundStyle))
						}
					}
					.accessibilityLabel(item.attack.label(.long))
					.accessibilityValue(text)
					.speechAdjustedPitch(item.isEmphasized ? 0.2 : 0)
			}
			.frame(width: itemWidth)

			let stunLabel = viewModel.stunLabel
			Text(viewModel.stunLabel)
				.accessibilityLabel("Stun")
				.accessibilityValue(stunLabel)
				.frame(width: itemWidth)
		}
		.foregroundStyle(viewModel.hierarchical)
		.accessibilityElement(children: .contain)
		.accessibilityLabel(Text(viewModel.accessibilityHeader))
	}
}

@available(macOS, unavailable)
struct ScrollablePhysiologyView: View {
	private static let physiologyCoordinateSpace = "physiology"

	let viewModel: PhysiologySectionViewModel

	@Environment(\.horizontalLayoutMargin)
	private var horizontalLayoutMargin

	@ScaledMetric(relativeTo: PhysiologyViewMetrics.textStyle)
	private var headerWidth: CGFloat = PhysiologyViewMetrics.headerBaseWidth

	@ScaledMetric(relativeTo: PhysiologyViewMetrics.textStyle)
	private var itemWidth: CGFloat = PhysiologyViewMetrics.itemBaseWidth

#if os(watchOS)
	@ScaledMetric(relativeTo: PhysiologyViewMetrics.textStyle)
	private var spacing: CGFloat = PhysiologyViewMetrics.spacing
#else
	@Environment(\.pixelLength)
	private var pixelLength

	@ScaledMetric(relativeTo: PhysiologyViewMetrics.textStyle)
	private var baseSpacing: CGFloat = PhysiologyViewMetrics.spacing

	@ScaledMetric(relativeTo: PhysiologyViewMetrics.textStyle)
	private var maxContentWidth: CGFloat = PhysiologyViewMetrics.baseMaxContentWidth

	@State
	private var rowMinWidth: CGFloat = 220.0

	@State
	private var spacing: CGFloat = PhysiologyViewMetrics.spacing
#endif

	@State
	private var headerHeights: [UInt32: CGFloat] = [:]

	@State
	private var isBorderShown: Bool = false

	var body: some View {
		HStack(alignment: .bottom, spacing: 0) {
#if os(watchOS)
			let baseSpacing = spacing
#endif
			let itemFrameWidth = (horizontalLayoutMargin - PhysiologyViewMetrics.margin.leading) + headerWidth + baseSpacing
			let headerBackground = Self.headerBackground
			let headerInsets = self.headerInsets
			VStack(spacing: 0) {
				ForEach(viewModel.groups) { group in
					VStack(spacing: 0) {
						ForEach(group.items) { item in
							_ScrollablePhysiologyHeaderView(viewModel: item)
						}
					}
					.padding(headerInsets)
					.frame(maxWidth: itemFrameWidth)
					.background(group.id % 2 != 0 ? headerBackground : nil)
				}
			}
			.multilineTextAlignment(.center)
			.fixedSize(horizontal: false, vertical: true)
			.accessibilityHidden(true)
			.padding(.bottom, PhysiologyViewMetrics.margin.bottom)
			.onPreferenceChange(PhysiologyHeaderHeightPreferenceKey.self) { heights in
				headerHeights = heights
			}

			let contentBackground = Self.contentBackground
			let contentInsets = self.contentInsets
			let coordSpace = "\(Self.physiologyCoordinateSpace):\(viewModel.id)"
			ScrollView(.horizontal) {
				VStack(spacing: 0) {
					_ScrollablePhysiologyRowHeaderView(viewModel: viewModel.columns,
													   itemWidth: itemWidth,
													   spacing: spacing)
#if !os(watchOS)
					.frame(minWidth: rowMinWidth, alignment: .leading)
#endif

					ForEach(viewModel.groups) { group in
						VStack(spacing: 0) {
							ForEach(group.items) { item in
								_ScrollablePhysiologyContentView(viewModel: item,
																 itemWidth: itemWidth,
																 spacing: spacing)
									.frame(height: headerHeights[item.id])
							}
						}
						.padding(contentInsets)
#if !os(watchOS)
						.frame(minWidth: rowMinWidth, alignment: .leading)
#endif
						.background(group.id % 2 != 0 ? contentBackground : nil)
					}
				}
				.padding(PhysiologyViewMetrics.margin.setting(leading: 0))
				.background(ScrollViewOffsetXDetector(coordinateSpace: coordSpace, result: $isBorderShown) { offsetX in
					offsetX < 0.0
				})
			}
			.coordinateSpace(name: coordSpace)
			.ignoresSafeArea(.all, edges: .leading)
			.backport.scrollBounceBehavior(.basedOnSize, axes: .horizontal)
			.overlay(alignment: .topLeading) {
				Group {
					if isBorderShown {
						HBorderView()
					}
				}
				.animation(.easeInOut(duration: 0.1), value: isBorderShown)
			}
#if !os(watchOS)
			.onWidthChange { scrollViewWidth in
				rowMinWidth = scrollViewWidth - PhysiologyViewMetrics.margin.trailing
			}
			.onChange(of: rowMinWidth) { newRowMinWidth in
				let count: CGFloat = CGFloat(viewModel.columns.count + 1 /* Stun */)
				let calcSpacing: CGFloat = pixelLength * floor((min(newRowMinWidth, maxContentWidth) - itemWidth * count - PhysiologyViewMetrics.padding.trailing) / pixelLength / count)
				spacing = max(baseSpacing, calcSpacing)
			}
#endif
		}
		.font(.system(PhysiologyViewMetrics.textStyle).monospacedDigit().leading(.tight))
		.minimumScaleFactor(0.5)
		.padding(.leading, PhysiologyViewMetrics.margin.leading)

		// Disable animations.
		.animation(nil, value: headerHeights)
#if !os(watchOS)
		.animation(nil, value: rowMinWidth)
		.animation(nil, value: spacing)
#endif
		.transition(.identity)
	}

	private var headerInsets: EdgeInsets {
#if os(watchOS)
		let baseSpacing = spacing
#endif
		return EdgeInsets(top: PhysiologyViewMetrics.padding.top,
						  leading: horizontalLayoutMargin - PhysiologyViewMetrics.margin.leading,
						  bottom: PhysiologyViewMetrics.padding.bottom,
						  trailing: baseSpacing)
	}

	private var contentInsets: EdgeInsets {
#if os(watchOS)
		let baseSpacing = spacing
#endif
		return EdgeInsets(top: PhysiologyViewMetrics.padding.top,
						  leading: spacing,
						  bottom: PhysiologyViewMetrics.padding.bottom,
						  trailing: horizontalLayoutMargin - PhysiologyViewMetrics.margin.trailing)
	}

	private static var headerBackground: some View {
		if #available(iOS 16.0, watchOS 9.0, *) {
			return UnevenRoundedRectangle(topLeadingRadius: PhysiologyViewMetrics.cornerRadius,
										  bottomLeadingRadius: PhysiologyViewMetrics.cornerRadius)
				.foregroundColor(.physiologySecondary)
				.flipsForRightToLeftLayoutDirection(true)
		} else {
			return UnevenRoundedRectangleBackport(cornerRadius: PhysiologyViewMetrics.cornerRadius,
												  corner: .left)
				.foregroundColor(.physiologySecondary)
				.flipsForRightToLeftLayoutDirection(true)
		}
	}

	private static var contentBackground: some View {
		if #available(iOS 16.0, watchOS 9.0, *) {
			return UnevenRoundedRectangle(bottomTrailingRadius: PhysiologyViewMetrics.cornerRadius,
										  topTrailingRadius: PhysiologyViewMetrics.cornerRadius)
				.foregroundColor(.physiologySecondary)
				.flipsForRightToLeftLayoutDirection(true)
		} else {
			return UnevenRoundedRectangleBackport(cornerRadius: PhysiologyViewMetrics.cornerRadius,
												  corner: .right)
				.foregroundColor(.physiologySecondary)
				.flipsForRightToLeftLayoutDirection(true)
		}
	}
}

@available(macOS, unavailable)
struct HeaderScrollablePhysiologyView: View {
	let viewModel: PhysiologySectionViewModel
	let headerHidden: Bool

#if !os(watchOS)
	@ScaledMetric(relativeTo: .body)
	private var verticalPadding: CGFloat = 11.0
#endif

	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			if !viewModel.isDefault {
				MAItemHeader(header: viewModel.header)
#if os(watchOS)
					.padding(.top, PhysiologyViewMetrics.margin.top)
#else
					.padding(.top, verticalPadding)
#endif
			}

			ScrollablePhysiologyView(viewModel: viewModel)
				.dynamicTypeSize(...DynamicTypeSize.accessibility3)
		}
	}
}

@available(macOS, unavailable)
#Preview("Default") {
	let data = MockDataSource.physiology1
	let viewModel = PhysiologiesViewModel(version: data.version, physiology: data.modes[0])
	return Form {
		ScrollablePhysiologyView(viewModel: viewModel.sections[0])
			.listRowInsets(.zero)
	}
}

@available(macOS, unavailable)
#Preview("Right-to-Left") {
	let data = MockDataSource.physiology1
	let viewModel = PhysiologiesViewModel(version: data.version, physiology: data.modes[0])
	return Form {
		ScrollablePhysiologyView(viewModel: viewModel.sections[0])
			.listRowInsets(.zero)
	}
	.environment(\.locale, Locale(identifier: "ar"))
	.environment(\.layoutDirection, .rightToLeft)
}
