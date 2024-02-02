import MonsterAnalyzerCore
import SwiftUI

struct WeaknessView: View {
	let viewModel: WeaknessViewModel

#if os(iOS) || os(watchOS)
	@Environment(\.dynamicTypeSize.isAccessibilitySize)
	private var isAccessibilitySize
#endif

	var body: some View {
#if os(macOS)
		VSpacer(spacing: 5.0) {
			ForEach(viewModel.sections) { section in
				WeaknessSectionView(viewModel: section)
			}
		}
#else
		if isAccessibilitySize {
			ForEach(viewModel.sections) { section in
				AccessibilityWeaknessSectionView(viewModel: section)
			}
		} else {
#if os(watchOS)
			ForEach(viewModel.sections) { section in
				WeaknessSectionView(viewModel: section)
			}
#else
			VSpacer(spacing: 5.0) {
				ForEach(viewModel.sections) { section in
					WeaknessSectionView(viewModel: section)
				}
			}
#endif
		}
#endif
	}
}

#Preview("Sign") {
	let viewModel = WeaknessViewModel(prefixID: "mock",
									  physiology: MockDataSource.physiology1.modes[0],
									  options: MonsterDataViewModelBuildOptions(physical: true, element: .sign))
	return Form {
		WeaknessView(viewModel: viewModel)
	}
}

#Preview("Number") {
	let viewModel = WeaknessViewModel(prefixID: "mock",
									  physiology: MockDataSource.physiology1.modes[0],
									  options: MonsterDataViewModelBuildOptions(physical: true, element: .number))
	return Form {
		WeaknessView(viewModel: viewModel)
	}
}

#Preview("Number2") {
	let viewModel = WeaknessViewModel(prefixID: "mock",
									  physiology: MockDataSource.physiology1.modes[0],
									  options: MonsterDataViewModelBuildOptions(physical: true, element: .number2))
	return Form {
		WeaknessView(viewModel: viewModel)
	}
}
