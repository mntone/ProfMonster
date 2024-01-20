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
				.frame(minHeight: defaultMinListHeaderHeight)
				.padding(EdgeInsets(top: 5.0,
									leading: horizontalLayoutMargin,
									bottom: 11.0,
									trailing: horizontalLayoutMargin))
		} else {
			header
				.textCase(.uppercase)
				.font(.footnote)
				.foregroundStyle(.secondary)
				.frame(minHeight: defaultMinListHeaderHeight)
				.padding(EdgeInsets(top: 18.0,
									leading: horizontalLayoutMargin,
									bottom: 5.0,
									trailing: horizontalLayoutMargin))
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
