import SwiftUI

struct MASectionHeader: View {
	let header: Text

#if os(iOS) || os(macOS)
	@Environment(\.defaultMinListHeaderHeight)
	private var defaultMinListHeaderHeight
#endif

#if os(iOS)
	@Environment(\.defaultMinListRowHeight)
	private var defaultMinListRowHeight
#endif

	@Environment(\.headerProminence)
	private var headerProminence

#if os(iOS) || os(macOS)
	@Environment(\.horizontalLayoutMargin)
	private var horizontalLayoutMargin
#endif

	init<S>(_ title: S) where S: StringProtocol {
		self.header = Text(title)
	}

	init(_ titleKey: LocalizedStringKey, tableName: String? = nil, bundle: Bundle? = nil, comment: StaticString? = nil) {
		self.header = Text(titleKey,
						   tableName: tableName,
						   bundle: bundle,
						   comment: comment)
	}

	var body: some View {
#if os(iOS)
		if headerProminence == .increased {
			header
				.font(.title3.bold())
				.padding(EdgeInsets(top: 0.0,
									leading: horizontalLayoutMargin,
									bottom: 12.0,
									trailing: horizontalLayoutMargin))
				.frame(minHeight: defaultMinListHeaderHeight ?? defaultMinListRowHeight,
					   alignment: .bottomLeading)
				// [SwiftUI.ListStyle.insetGrouped default style, not Apple Design Resources]
				//.padding(EdgeInsets(top: 0.0,
				//					leading: horizontalLayoutMargin,
				//					bottom: 11.0,
				//					trailing: horizontalLayoutMargin))
				//.frame(minHeight: max((defaultMinListHeaderHeight ?? defaultMinListRowHeight) - 1.0, 0.0),
				//	   alignment: .bottomLeading)
		} else {
			header
				.textCase(.uppercase)
				.font(.footnote)
				.foregroundStyle(.secondary)
				.padding(EdgeInsets(top: 0.0,
									leading: horizontalLayoutMargin,
									bottom: 8.0,
									trailing: horizontalLayoutMargin))
				.frame(minHeight: defaultMinListHeaderHeight ?? defaultMinListRowHeight,
					   alignment: .bottomLeading)
		}
#elseif os(macOS)
		header
			.font(headerProminence == .increased ? .title3.bold() : .headline)
			.frame(minHeight: defaultMinListHeaderHeight)
			.padding(EdgeInsets(top: 20.0,
								leading: horizontalLayoutMargin,
								bottom: 10.0,
								trailing: horizontalLayoutMargin))
#else
		header.font(headerProminence == .increased ? .headline : .footnote)
#endif
	}
}
