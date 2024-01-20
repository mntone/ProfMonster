import SwiftUI

struct MASectionFooter: View {
	let footer: Text

#if os(iOS) || os(macOS)
	@Environment(\.horizontalLayoutMargin)
	private var horizontalLayoutMargin
#endif

	init<S>(_ title: S) where S: StringProtocol {
		self.footer = Text(title)
	}

	init(_ titleKey: LocalizedStringKey, tableName: String? = nil, bundle: Bundle? = nil, comment: StaticString? = nil) {
		self.footer = Text(titleKey,
						   tableName: tableName,
						   bundle: bundle,
						   comment: comment)
	}

	var body: some View {
		footer
#if os(iOS)
			.font(.footnote)
			.foregroundStyle(.secondary)
			.padding(EdgeInsets(top: 5.0,
								leading: horizontalLayoutMargin,
								bottom: 18.0,
								trailing: horizontalLayoutMargin))
#elseif os(macOS)
			.foregroundStyle(.secondary)
			.padding(.top, 10.0)
			.frame(maxWidth: .infinity, alignment: .trailing)
#endif
	}
}
