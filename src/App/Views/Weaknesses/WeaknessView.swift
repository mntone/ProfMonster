import MonsterAnalyzerCore
import SwiftUI

struct WeaknessView: View {
	let viewModel: any WeaknessViewModel

	var body: some View {
#if os(watchOS)
		switch viewModel {
		case let effectivenessViewModel as EffectivenessWeaknessViewModel:
			ForEach(effectivenessViewModel.sections) { section in
				SignWeaknessSectionView(viewModel: section)
			}
			.lineLimit(1)
		case let numberViewModel as NumberWeaknessViewModel:
			ForEach(numberViewModel.sections) { section in
				SignWeaknessSectionView(viewModel: section)
			}
			.lineLimit(1)
		default:
			Never?.none
		}
#else
		switch viewModel {
		case let effectiveness as EffectivenessWeaknessViewModel:
			let alignment: HorizontalAlignment = viewModel.displayMode == .sign ? .center : .leading
			ForEach(effectiveness.sections) { section in
				SignWeaknessSectionView(
					alignment: alignment,
					viewModel: section)
			}
			.lineLimit(1)
		case let number as NumberWeaknessViewModel:
			switch viewModel.displayMode {
			case .none:
				Never?.none
			case .sign:
				ForEach(number.sections) { section in
					SignWeaknessSectionView(alignment: .center,
											viewModel: section)
				}
				.lineLimit(1)
			case .number, .number2:
				let fractionLength: Int = viewModel.displayMode == .number2 ? 2 : 1
				ForEach(number.sections) { section in
					NumberWeaknessSectionView(fractionLength: fractionLength,
											  viewModel: section)
				}
				.lineLimit(1)
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
