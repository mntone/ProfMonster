import MonsterAnalyzerCore
import SwiftUI

enum PhysiologyViewMetrics {
#if os(macOS)
	static let textStyle: Font.TextStyle = .body
	static let defaultFontSize: CGFloat = 13
	static let headerBaseWidth: CGFloat = 100
	static let itemBaseWidth: CGFloat = 24
	static let maxWidth: CGFloat = 500

	static let margin: CGFloat = 4
	static let scrollMargin: CGFloat = 12
	static let spacing: CGFloat = 8
	static let rowSpacing: CGFloat = 4
	static let inset: CGFloat = 12
#elseif os(watchOS)
	static let textStyle: Font.TextStyle = .caption2
	static let defaultFontSize: CGFloat = 14
	static let headerBaseWidth: CGFloat = 50
	static let itemBaseWidth: CGFloat = 20

	static let margin: CGFloat = 2
	static let scrollMargin: CGFloat = 8
	static let spacing: CGFloat = 4
	static let rowSpacing: CGFloat = 2
	static let inset: CGFloat = 8
#else
	static let maxScaleFactor: CGFloat = 1.9

	static let textStyle: Font.TextStyle = .subheadline
	static let defaultFontSize: CGFloat = 15
	static let headerBaseWidth: CGFloat = 88
	static let itemBaseWidth: CGFloat = 24
	static let maxWidth: CGFloat = 480

	static let margin: CGFloat = 8
	static let scrollMargin: CGFloat = 12
	static let spacing: CGFloat = 8
	static let rowSpacing: CGFloat = 4
	static let inset: CGFloat = 12
#endif

	static let rowPadding: EdgeInsets = EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12)
}

struct PhysiologyHeaderHeightPreferenceKey: PreferenceKey {
	static var defaultValue: [PhysiologyViewModel.ID: CGFloat] = [:]

	static func reduce(value: inout [PhysiologyViewModel.ID: CGFloat], nextValue: () -> [PhysiologyViewModel.ID: CGFloat]) {
		value.merge(nextValue()) { cur, next in next }
	}
}

private struct PhysiologyRowHeaderView: View {
	let viewModel: [PhysiologyColumnViewModel]
	let itemWidth: CGFloat

	var body: some View {
		HStack(spacing: PhysiologyViewMetrics.spacing) {
			ForEach(viewModel) { item in
				Image(systemName: item.attackImageName)
					.foregroundColor(item.attackColor)
			}
			.frame(maxWidth: itemWidth)
		}
		.padding(EdgeInsets(top: PhysiologyViewMetrics.rowSpacing,
							leading: PhysiologyViewMetrics.margin,
							bottom: PhysiologyViewMetrics.rowSpacing,
							trailing: PhysiologyViewMetrics.inset))
	}
}

struct PhysiologyHeaderView: View {
	let viewModel: PhysiologyViewModel

	var body: some View {
		Text(verbatim: viewModel.header)
			.foregroundColor(viewModel.foregroundColor)
			.background(GeometryReader { proxy in
				Color.clear.preference(key: PhysiologyHeaderHeightPreferenceKey.self,
									   value: [viewModel.id: proxy.size.height])
			})
			.padding(EdgeInsets(top: 0,
								leading: PhysiologyViewMetrics.inset,
								bottom: 0,
								trailing: PhysiologyViewMetrics.margin))
	}
}

struct PhysiologyContentView: View {
	let viewModel: PhysiologyViewModel
	let itemWidth: CGFloat

	var body: some View {
		HStack(spacing: PhysiologyViewMetrics.spacing) {
			ForEach(Array(viewModel.values.enumerated()), id: \.offset) { _, val in
				Text(verbatim: String(val))
			}
			.frame(width: itemWidth)
		}
		.foregroundColor(viewModel.foregroundColor)
		.padding(EdgeInsets(top: 0,
							leading: PhysiologyViewMetrics.margin,
							bottom: 0,
							trailing: PhysiologyViewMetrics.inset))
	}
}

struct PhysiologyScrollableView: View {
	let viewModel: PhysiologySectionViewModel

	@Environment(\.layoutDirection)
	private var layoutDirection

#if os(iOS)
	@ScaledMetric(relativeTo: PhysiologyViewMetrics.textStyle)
	private var fontSize: CGFloat = PhysiologyViewMetrics.defaultFontSize
#endif

#if !os(macOS)
	@ScaledMetric(relativeTo: PhysiologyViewMetrics.textStyle)
	private var headerWidth: CGFloat = PhysiologyViewMetrics.headerBaseWidth

	@ScaledMetric(relativeTo: PhysiologyViewMetrics.textStyle)
	private var itemWidth: CGFloat = PhysiologyViewMetrics.itemBaseWidth
#endif

	@State
	private var headerHeights: [UInt32: CGFloat] = [:]

	@State
	private var offsetX: CGFloat = 0

	var body: some View {
#if os(iOS)
		let cappedHeaderWidth = min(headerWidth, PhysiologyViewMetrics.maxScaleFactor * PhysiologyViewMetrics.headerBaseWidth)
		let cappedItemWidth = min(itemWidth, PhysiologyViewMetrics.maxScaleFactor * PhysiologyViewMetrics.itemBaseWidth)
#endif

		HStack(alignment: .bottom, spacing: 0) {
			let headerBackground = headerBackgroundShape.foregroundColor(.physiologySecondary)
			VStack(spacing: 0) {
				ForEach(viewModel.groups) { group in
					VStack(spacing: 0) {
						ForEach(group.items) { item in
							PhysiologyHeaderView(viewModel: item)
						}
					}
					.padding(.vertical, PhysiologyViewMetrics.rowSpacing)
					.frame(maxWidth: .infinity)
					.background(group.id % 2 != 0 ? headerBackground : nil)
				}
			}
			.multilineTextAlignment(.center)
			.fixedSize(horizontal: false, vertical: true)
#if os(iOS)
			.frame(maxWidth: cappedHeaderWidth)
#elseif os(macOS)
			.frame(maxWidth: PhysiologyViewMetrics.headerBaseWidth)
#else
			.frame(maxWidth: headerWidth)
#endif
			.padding(.bottom, PhysiologyViewMetrics.rowSpacing)
			.onPreferenceChange(PhysiologyHeaderHeightPreferenceKey.self) { heights in
				headerHeights = heights
			}

			let contentBackground = contentBackgroundShape.foregroundColor(.physiologySecondary)
			ObservableHorizontalScrollView(offsetX: $offsetX) {
				VStack(spacing: 0) {
#if os(iOS)
					PhysiologyRowHeaderView(viewModel: viewModel.columns,
											itemWidth: cappedItemWidth)
#elseif os(macOS)
					PhysiologyRowHeaderView(viewModel: viewModel.columns,
											itemWidth: PhysiologyViewMetrics.itemBaseWidth)
#else
					PhysiologyRowHeaderView(viewModel: viewModel.columns,
											itemWidth: itemWidth)
#endif

					ForEach(viewModel.groups) { group in
						VStack(spacing: 0) {
							ForEach(group.items) { item in
#if os(iOS)
								PhysiologyContentView(viewModel: item,
													  itemWidth: cappedItemWidth)
									.frame(height: headerHeights[item.id])
#elseif os(macOS)
								PhysiologyContentView(viewModel: item,
													  itemWidth: PhysiologyViewMetrics.itemBaseWidth)
									.frame(height: headerHeights[item.id])
#else
								PhysiologyContentView(viewModel: item,
													  itemWidth: itemWidth)
									.frame(height: headerHeights[item.id])
#endif
							}
						}
						.padding(.vertical, PhysiologyViewMetrics.rowSpacing)
						.background(group.id % 2 != 0 ? contentBackground : nil)
					}
				}
				.padding(EdgeInsets(top: PhysiologyViewMetrics.rowSpacing,
									leading: 0,
									bottom: PhysiologyViewMetrics.rowSpacing,
									trailing: PhysiologyViewMetrics.scrollMargin))
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
		.padding(.leading, PhysiologyViewMetrics.margin)
#if os(iOS)
		.font(.system(size: min(fontSize, PhysiologyViewMetrics.maxScaleFactor * PhysiologyViewMetrics.defaultFontSize)).monospacedDigit())
#else
		.font(.system(PhysiologyViewMetrics.textStyle).monospacedDigit())
#endif
	}

	private var isLTR: Bool {
		layoutDirection == .rightToLeft
	}

	private var headerBackgroundShape: some Shape {
		if #available(iOS 16.0, macOS 13.0, watchOS 9.0, *) {
			return isLTR
				? UnevenRoundedRectangle(bottomTrailingRadius: 4, topTrailingRadius: 4)
				: UnevenRoundedRectangle(topLeadingRadius: 4, bottomLeadingRadius: 4)
		} else {
			return UnevenRoundedRectangleBackport(cornerRadius: 4, corner: isLTR ? .right : .left)
		}
	}

	private var contentBackgroundShape: some Shape {
		if #available(iOS 16.0, macOS 13.0, watchOS 9.0, *) {
            return isLTR
				? UnevenRoundedRectangle(topLeadingRadius: 4, bottomLeadingRadius: 4)
				: UnevenRoundedRectangle(bottomTrailingRadius: 4, topTrailingRadius: 4)
		} else {
			return UnevenRoundedRectangleBackport(cornerRadius: 4, corner: isLTR ? .left : .right)
		}
	}
}

// In this case, happen that ScrollView is invalid position with LTR UI (watchOS only).
// Add `.padding(.leading, isLTR ? 2 : 0)` to ScrollView if you need.
// But, in real case, its sentence is unnessesary.
#Preview {
	PhysiologyScrollableView(viewModel: PhysiologiesViewModel(rawValue: MockDataSource.physiology1).sections[0])
		.previewLayout(.sizeThatFits)
		//.environment(\.locale, Locale(identifier: "ar"))
		//.environment(\.layoutDirection, .rightToLeft)
}
