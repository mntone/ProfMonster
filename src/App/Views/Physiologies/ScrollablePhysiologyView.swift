import MonsterAnalyzerCore
import SwiftUI

#if !os(macOS)

@available(macOS, unavailable)
struct PhysiologyHeaderHeightPreferenceKey: PreferenceKey {
	static var defaultValue: [PhysiologyViewModel.ID: CGFloat] = [:]

	static func reduce(value: inout [PhysiologyViewModel.ID: CGFloat], nextValue: () -> [PhysiologyViewModel.ID: CGFloat]) {
		value.merge(nextValue()) { cur, next in next }
	}
}

@available(macOS, unavailable)
private struct _ScrollablePhysiologyRowHeaderView: View {
	let viewModel: [PhysiologyColumnViewModel]
	let itemWidth: CGFloat
	let spacing: CGFloat

	var body: some View {
		HStack(spacing: spacing) {
			ForEach(viewModel) { item in
				Image(systemName: item.attack.imageName)
#if !os(watchOS)
					.help(item.attack.longLabel)
#endif
					.foregroundStyle(item.attack.color)
			}
			.frame(maxWidth: itemWidth)

			Image(systemName: "star.fill")
#if !os(watchOS)
				.help("Stun")
#endif
				.foregroundStyle(.thunder)
				.frame(width: itemWidth)
		}
		.padding(PhysiologyViewMetrics.padding.setting(leading: PhysiologyViewMetrics.margin.leading))
		.accessibilityHidden(true)
	}
}

@available(macOS, unavailable)
private struct _ScrollablePhysiologyHeaderView: View {
	let viewModel: PhysiologyViewModel

	var body: some View {
		Text(verbatim: viewModel.header)
			.foregroundStyle(viewModel.foregroundShape)
			.background(GeometryReader { proxy in
				Color.clear.preference(key: PhysiologyHeaderHeightPreferenceKey.self,
									   value: [viewModel.id: proxy.size.height])
			})
			.padding(EdgeInsets(top: 0,
								leading: PhysiologyViewMetrics.padding.leading,
								bottom: 0,
								trailing: PhysiologyViewMetrics.margin.trailing))
	}
}

@available(macOS, unavailable)
private struct _ScrollablePhysiologyContentView: View {
	let viewModel: PhysiologyViewModel
	let itemWidth: CGFloat
	let spacing: CGFloat

	var body: some View {
		HStack(spacing: spacing) {
			ForEach(viewModel.values) { item in
				let text = Text(verbatim: String(item.value))
				text
					.accessibilityLabel(item.attack.longLabel)
					.accessibilityValue(text)
			}
			.frame(width: itemWidth)

			let stunLabel = viewModel.stunLabel
			Text(verbatim: viewModel.stunLabel)
				.accessibilityLabel("Stun")
				.accessibilityValue(stunLabel)
				.frame(width: itemWidth)
		}
		.foregroundStyle(viewModel.foregroundShape)
		.accessibilityElement(children: .contain)
		.accessibilityLabel(Text(verbatim: viewModel.accessibilityHeader))
	}
}

@available(macOS, unavailable)
struct ScrollablePhysiologyView: View {
	let viewModel: PhysiologySectionViewModel

#if os(iOS)
	@ScaledMetric(relativeTo: PhysiologyViewMetrics.textStyle)
	private var fontSize: CGFloat = PhysiologyViewMetrics.defaultFontSize
#endif

	@ScaledMetric(relativeTo: PhysiologyViewMetrics.textStyle)
	private var headerWidth: CGFloat = PhysiologyViewMetrics.headerBaseWidth

	@ScaledMetric(relativeTo: PhysiologyViewMetrics.textStyle)
	private var itemWidth: CGFloat = PhysiologyViewMetrics.itemBaseWidth

	@ScaledMetric(relativeTo: PhysiologyViewMetrics.textStyle)
	private var spacing: CGFloat = PhysiologyViewMetrics.spacing

	@State
	private var headerHeights: [UInt32: CGFloat] = [:]

	@State
	private var offsetX: CGFloat = 0

	var body: some View {
#if os(iOS)
		let cappedHeaderWidth = min(headerWidth, PhysiologyViewMetrics.maxScaleFactor * PhysiologyViewMetrics.headerBaseWidth)
		let cappedItemWidth = min(itemWidth, PhysiologyViewMetrics.maxScaleFactor * PhysiologyViewMetrics.itemBaseWidth)
		let cappedFontSize = min(fontSize, PhysiologyViewMetrics.maxScaleFactor * PhysiologyViewMetrics.defaultFontSize)
		let cappedSpacing = min(spacing, PhysiologyViewMetrics.maxScaleFactor * PhysiologyViewMetrics.spacing)
#endif

		HStack(alignment: .bottom, spacing: 0) {
			let headerBackground = Self.headerBackground
			VStack(spacing: 0) {
				ForEach(viewModel.groups) { group in
					VStack(spacing: 0) {
						ForEach(group.items) { item in
							_ScrollablePhysiologyHeaderView(viewModel: item)
						}
					}
					.padding(PhysiologyViewMetrics.padding.setting(horizontal: 0))
					.frame(maxWidth: .infinity)
					.background(group.id % 2 != 0 ? headerBackground : nil)
				}
			}
			.multilineTextAlignment(.center)
			.fixedSize(horizontal: false, vertical: true)
			.accessibilityHidden(true)
#if os(watchOS)
			.frame(maxWidth: headerWidth)
#else
			.frame(maxWidth: cappedHeaderWidth)
#endif
			.padding(.bottom, PhysiologyViewMetrics.margin.bottom)
			.onPreferenceChange(PhysiologyHeaderHeightPreferenceKey.self) { heights in
				headerHeights = heights
			}

			let contentBackground = Self.contentBackground
			ObservableHorizontalScrollView(offsetX: $offsetX) {
				VStack(spacing: 0) {
#if os(watchOS)
					_ScrollablePhysiologyRowHeaderView(viewModel: viewModel.columns,
													   itemWidth: itemWidth,
													   spacing: spacing)
#else
					_ScrollablePhysiologyRowHeaderView(viewModel: viewModel.columns,
													   itemWidth: cappedItemWidth,
													   spacing: cappedSpacing)
#endif

					ForEach(viewModel.groups) { group in
						VStack(spacing: 0) {
							ForEach(group.items) { item in
#if os(watchOS)
								_ScrollablePhysiologyContentView(viewModel: item,
																 itemWidth: itemWidth,
																 spacing: spacing)
									.frame(height: headerHeights[item.id])
#else
								_ScrollablePhysiologyContentView(viewModel: item,
																 itemWidth: cappedItemWidth,
																 spacing: cappedSpacing)
									.frame(height: headerHeights[item.id])
#endif
							}
						}
						.padding(PhysiologyViewMetrics.padding.setting(leading: PhysiologyViewMetrics.margin.leading))
						.background(group.id % 2 != 0 ? contentBackground : nil)
					}
				}
				.padding(PhysiologyViewMetrics.margin.setting(leading: 0))
			}
			.ignoresSafeArea(.all, edges: .leading)
			.overlay(alignment: .topLeading) {
				Group {
					if offsetX > 0 {
						HBorderView().offset(x: -HBorderView.length)
					}
				}.animation(.easeInOut(duration: 0.1),
							value: offsetX > 0)
			}
		}
		.padding(.leading, PhysiologyViewMetrics.margin.leading)
#if os(watchOS)
		.font(.system(PhysiologyViewMetrics.textStyle).monospacedDigit())
#else
		.font(.system(size: cappedFontSize).monospacedDigit())
#endif
		.minimumScaleFactor(0.5)
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
#Preview("Default") {
	let viewModel = PhysiologiesViewModel(rawValue: MockDataSource.physiology1)
	return Form {
		ScrollablePhysiologyView(viewModel: viewModel.sections[0])
			.listRowInsets(.zero)
	}
}

@available(macOS, unavailable)
#Preview("Right-to-Left") {
	let viewModel = PhysiologiesViewModel(rawValue: MockDataSource.physiology1)
	return Form {
		ScrollablePhysiologyView(viewModel: viewModel.sections[0])
			.listRowInsets(.zero)
	}
	.environment(\.locale, Locale(identifier: "ar"))
	.environment(\.layoutDirection, .rightToLeft)
}

#endif
