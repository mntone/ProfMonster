import SwiftUI

struct PhysiologySection: View {
	let physiologies: PhysiologiesViewModel?

	var body: some View {
		MASection("Physiology", background: .separatedInsetGrouped) {
			if let physiologies {
				let headerHidden = physiologies.sections.count <= 1
				ForEach(physiologies.sections) { section in
#if os(macOS)
					PhysiologyView(viewModel: section, headerHidden: headerHidden)
#else
					HeaderScrollablePhysiologyView(viewModel: section,
												   headerHidden: headerHidden)
#endif
				}
			} else {
				ProgressIndicatorView()
#if os(watchOS)
					.padding(.vertical, 20)
#else
					.padding(.vertical, 40)
#endif
					.frame(maxWidth: .infinity)
			}
		} footer: {
			if let version = physiologies?.version {
				MASectionFooter(LocalizedStringKey("Version \(version)"))
			}
		}
#if os(iOS) || os(watchOS)
		.ignoreLayoutMargin()
#endif
	}
}
