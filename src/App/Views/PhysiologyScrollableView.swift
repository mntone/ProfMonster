import MonsterAnalyzerCore
import SwiftUI

struct PhysiologyViewMetrics {
#if os(watchOS)
	static let textStyle: Font.TextStyle = .caption2
	static let headerBaseWidth: CGFloat = 45
	static let itemBaseWidth: CGFloat = 20

	static let margin: CGFloat = 2
	static let scrollMargin: CGFloat = 8
	static let spacing: CGFloat = 2
	static let inset: CGFloat = 8
#else
	static let textStyle: Font.TextStyle = .callout
	static let headerBaseWidth: CGFloat = 75
	static let itemBaseWidth: CGFloat = 24

	static let margin: CGFloat = 4
	static let scrollMargin: CGFloat = 12
	static let spacing: CGFloat = 4
	static let inset: CGFloat = 12
#endif

	static let rowPadding: EdgeInsets = EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12)
}

struct PhysiologyHeaderHeightPreferenceKey: PreferenceKey {
	static var defaultValue: [String: CGFloat] = [:]

	static func reduce(value: inout [String: CGFloat], nextValue: () -> [String: CGFloat]) {
		value.merge(nextValue()) { cur, next in next }
	}
}

struct PhysiologyHeaderView: View {
	let viewModel: PhysiologyViewModel

	@ScaledMetric(relativeTo: PhysiologyViewMetrics.textStyle)
	private var headerWidth: CGFloat = PhysiologyViewMetrics.headerBaseWidth

	var body: some View {
		Text(verbatim: viewModel.header)
			.multilineTextAlignment(.center)
			.fixedSize(horizontal: false, vertical: true)
			.frame(width: headerWidth)
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

	@ScaledMetric(relativeTo: PhysiologyViewMetrics.textStyle)
	private var itemWidth: CGFloat = PhysiologyViewMetrics.itemBaseWidth

	var body: some View {
		HStack {
			ForEach(Array(viewModel.value.values().enumerated()), id: \.offset) { _, val in
				Spacer()
				Text(verbatim: String(val))
					.frame(width: itemWidth)
			}
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

	@State
	private var headerHeights: [String: CGFloat] = [:]

	@State
	private var offsetX: CGFloat = 0

	var body: some View {
		HStack(spacing: 0) {
			VStack(spacing: 0) {
				ForEach(Array(viewModel.groups.enumerated()), id: \.offset) { i, group in
					VStack(spacing: 0) {
						ForEach(group.items) { item in
							PhysiologyHeaderView(viewModel: item)
						}
					}
					.padding(.vertical, PhysiologyViewMetrics.spacing)
					.background(i % 2 != 0
									? headerBackgroundShape.foregroundColor(.systemFill)
									: nil)
				}
			}
			.padding(.vertical, PhysiologyViewMetrics.margin)
			.onPreferenceChange(PhysiologyHeaderHeightPreferenceKey.self) { heights in
				headerHeights = heights
			}

			ObservableHorizontalScrollView(offsetX: $offsetX) {
				VStack(spacing: 0) {
					ForEach(Array(viewModel.groups.enumerated()), id: \.offset) { i, group in
						VStack(spacing: 0) {
							ForEach(group.items) { item in
								PhysiologyContentView(viewModel: item)
									.frame(height: headerHeights[item.id])
							}
						}
						.padding(.vertical, PhysiologyViewMetrics.spacing)
						.background(i % 2 != 0
									? contentBackgroundShape.foregroundColor(.systemFill)
									: nil)
					}
				}
				.padding(EdgeInsets(top: PhysiologyViewMetrics.margin,
									leading: 0,
									bottom: PhysiologyViewMetrics.margin,
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
		.font(.system(PhysiologyViewMetrics.textStyle).monospacedDigit())
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
	PhysiologyScrollableView(viewModel: PhysiologiesViewModel(rawValue: MHMockDataOffer.physiology1).sections[0])
		//.environment(\.locale, Locale(identifier: "ar"))
		//.environment(\.layoutDirection, .rightToLeft)
}
