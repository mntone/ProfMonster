import MonsterAnalyzerCore
import SwiftUI

struct WeaknessView: View {
	let viewModel: any WeaknessViewModel

#if os(iOS) || os(watchOS)
	@Environment(\.dynamicTypeSize.isAccessibilitySize)
	private var isAccessibilitySize
#endif

	var body: some View {
#if os(watchOS)
		switch viewModel {
		case let effectivenessViewModel as EffectivenessWeaknessViewModel:
			if isAccessibilitySize {
				ForEach(effectivenessViewModel.sections) { section in
					AccessibilitySignWeaknessSectionView(viewModel: section)
				}
			} else {
				ForEach(effectivenessViewModel.sections) { section in
					SignWeaknessSectionView(viewModel: section)
				}
				.lineLimit(1)
			}
		case let numberViewModel as NumberWeaknessViewModel:
			if isAccessibilitySize {
				ForEach(numberViewModel.sections) { section in
					AccessibilitySignWeaknessSectionView(viewModel: section)
				}
			} else {
				ForEach(numberViewModel.sections) { section in
					SignWeaknessSectionView(viewModel: section)
				}
				.lineLimit(1)
			}
		default:
			Never?.none
		}
#else
		switch viewModel {
		case let effectiveness as EffectivenessWeaknessViewModel:
			let alignment: HorizontalAlignment = viewModel.displayMode == .sign ? .center : .leading
#if os(macOS)
			MAFormMetricsBuilder { metrics in
				MAFormSeparatedRoundedBackground(metrics) {
					ForEach(effectiveness.sections) { section in
						SignWeaknessSectionView(
							alignment: alignment,
							viewModel: section)
					}
					.preferredVerticalPadding()
				}
			}
			.lineLimit(1)
#else
			if isAccessibilitySize {
				ForEach(effectiveness.sections) { section in
					AccessibilitySignWeaknessSectionView(viewModel: section)
				}
			} else {
				MAFormMetricsBuilder { metrics in
					MAFormSeparatedRoundedBackground(metrics) {
						ForEach(effectiveness.sections) { section in
							SignWeaknessSectionView(
								alignment: alignment,
								viewModel: section)
						}
						.preferredVerticalPadding()
					}
				}
				.lineLimit(1)
			}
#endif
		case let number as NumberWeaknessViewModel:
			switch viewModel.displayMode {
			case .none:
				Never?.none
			case .sign:
#if os(macOS)
				MAFormMetricsBuilder { metrics in
					MAFormSeparatedRoundedBackground(metrics) {
						ForEach(number.sections) { section in
							SignWeaknessSectionView(alignment: .center,
													viewModel: section)
						}
						.preferredVerticalPadding()
					}
				}
				.lineLimit(1)
#else
				if isAccessibilitySize {
					ForEach(number.sections) { section in
						AccessibilitySignWeaknessSectionView(viewModel: section)
					}
				} else {
					MAFormMetricsBuilder { metrics in
						MAFormSeparatedRoundedBackground(metrics) {
							ForEach(number.sections) { section in
								SignWeaknessSectionView(alignment: .center,
														viewModel: section)
							}
							.preferredVerticalPadding()
						}
					}
					.lineLimit(1)
				}
#endif
			case .number, .number2:
				let fractionLength: Int = viewModel.displayMode == .number2 ? 2 : 1
#if os(macOS)
				MAFormMetricsBuilder { metrics in
					MAFormSeparatedRoundedBackground(metrics) {
						ForEach(number.sections) { section in
							NumberWeaknessSectionView(fractionLength: fractionLength,
													  viewModel: section)
						}
						.preferredVerticalPadding()
					}
				}
				.lineLimit(1)
#else
				if isAccessibilitySize {
					ForEach(number.sections) { section in
						AccessibilityNumberWeaknessSectionView(fractionLength: fractionLength,
															   viewModel: section)
					}
				} else {
					MAFormMetricsBuilder { metrics in
						MAFormSeparatedRoundedBackground(metrics) {
							ForEach(number.sections) { section in
								NumberWeaknessSectionView(fractionLength: fractionLength,
														  viewModel: section)
							}
							.preferredVerticalPadding()
						}
					}
					.lineLimit(1)
				}
#endif
			}
		default:
			Never?.none
		}
#endif
	}
}

#Preview("Sign") {
	let viewModel = NumberWeaknessViewModel(prefixID: "mock",
											displayMode: .sign,
											rawValue: MockDataSource.physiology1)
	return Form {
		WeaknessView(viewModel: viewModel)
	}
}

#Preview("Number") {
	let viewModel = NumberWeaknessViewModel(prefixID: "mock",
											displayMode: .number,
											rawValue: MockDataSource.physiology1)
	return Form {
		WeaknessView(viewModel: viewModel)
	}
}

#Preview("Number2") {
	let viewModel = NumberWeaknessViewModel(prefixID: "mock",
											displayMode: .number2,
											rawValue: MockDataSource.physiology1)
	return Form {
		WeaknessView(viewModel: viewModel)
	}
}
