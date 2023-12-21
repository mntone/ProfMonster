import MonsterAnalyzerCore
import SwiftUI

struct WeaknessItemView: View {
	let viewModel: WeaknessItemViewModel

	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			Label {
				Text(viewModel.attackKey)
					.font(.callout.weight(.medium))
					.lineLimit(1)
			} icon: {
				viewModel.attackIcon
			}
			.foregroundColor(viewModel.attackColor)
			.padding(.bottom, 2)

			Text(String(format: "%.1f", viewModel.value))
				.font(.system(size: 20, weight: .bold, design: .rounded).monospacedDigit())
			//Text(viewModel.signKey)
			//	.font(.system(size: 16))
			//	.foregroundColor(viewModel.signColor)
		}
	}
}

@available(iOS 16.0, macOS 13.0, *)
struct HWrap: Layout {
	// inspired by: https://stackoverflow.com/a/75672314
	private let spacing: CGFloat
	public init(spacing: CGFloat? = nil) {
		self.spacing = spacing ?? 0
	}

	public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
		guard !subviews.isEmpty else { return .zero }

		let height = subviews.map { $0.sizeThatFits(proposal).height }.max() ?? 0

		var rowWidths = [CGFloat]()
		var currentRowWidth: CGFloat = 0
		subviews.forEach { subview in
			if currentRowWidth + spacing + subview.sizeThatFits(proposal).width >= proposal.width ?? 0 {
				rowWidths.append(currentRowWidth)
				currentRowWidth = subview.sizeThatFits(proposal).width
			} else {
				currentRowWidth += spacing + subview.sizeThatFits(proposal).width
			}
		}
		rowWidths.append(currentRowWidth)

		let rowCount = CGFloat(rowWidths.count)
		return CGSize(width: max(rowWidths.max() ?? 0, proposal.width ?? 0), height: rowCount * height + (rowCount - 1) * spacing)
	}

	public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
		let height = subviews.map { $0.dimensions(in: proposal).height }.max() ?? 0
		guard !subviews.isEmpty else { return }
		var x = bounds.minX
		var y = height / 2 + bounds.minY
		subviews.forEach { subview in
			x += subview.dimensions(in: proposal).width / 2
			if x + subview.dimensions(in: proposal).width / 2 > bounds.maxX {
				x = bounds.minX + subview.dimensions(in: proposal).width / 2
				y += height + spacing
			}
			subview.place(
				at: CGPoint(x: x, y: y),
				anchor: .center,
				proposal: ProposedViewSize(
					width: subview.dimensions(in: proposal).width,
					height: subview.dimensions(in: proposal).height
				)
			)
			x += subview.dimensions(in: proposal).width / 2 + spacing
		}
	}
}

@available(iOS 16.0, macOS 13.0, *)
struct WeaknessView: View {
	let viewModel: WeaknessSectionViewModel

	var body: some View {
		HWrap(spacing: 8) {
			ForEach(viewModel.items) { item in
				ZStack(alignment: .trailing) {
					HBorderView()
					WeaknessItemView(viewModel: item)
						.padding(.trailing, 8 + HBorderView.length)
				}
			}
		}
		.labelStyle(.titleOnly)
		.padding(4)
	}
}

@available(iOS 16.0, macOS 13.0, *)
#Preview {
	WeaknessView(viewModel: WeaknessViewModel(rawValue: MockDataSource.physiology1).sections[0])
		.previewLayout(.sizeThatFits)
}
