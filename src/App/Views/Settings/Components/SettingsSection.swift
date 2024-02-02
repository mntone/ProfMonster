import SwiftUI

struct SettingsSection<Content: View, Header: View, Footer: View>: View {
	let content: Content
	let header: Header?
	let footer: Footer?

	init(@ViewBuilder content: () -> Content) where Header == Never, Footer == Never {
		self.content = content()
		self.header = Never?.none
		self.footer = Never?.none
	}

	init(_ titleKey: LocalizedStringKey,
		 @ViewBuilder content: () -> Content) where Header == Text, Footer == Never {
		self.content = content()
		self.header = Text(titleKey)
		self.footer = Never?.none
	}

	init(@ViewBuilder content: () -> Content,
		 @ViewBuilder footer: () -> Footer) where Header == Never {
		self.content = content()
		self.header = Never?.none
		self.footer = footer()
	}

	init(@ViewBuilder content: () -> Content,
		 @ViewBuilder header: () -> Header,
		 @ViewBuilder footer: () -> Footer) {
		self.content = content()
		self.header = header()
		self.footer = footer()
	}

	var body: some View {
		Section {
			content
#if os(iOS)
				.listRowInsetsLayoutMargin()
#endif
		} header: {
			header
		} footer: {
			footer
		}
	}
}
