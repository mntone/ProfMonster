import SwiftUI

enum MASectionBackgroundStyle {
	case none

	@available(watchOS, unavailable)
	case insetGrouped

	case separatedInsetGrouped
}

struct MASection<Content: View, Footer: View>: View {
	let backgroundStyle: MASectionBackgroundStyle
	let content: Content
	let header: MASectionHeader
	let footer: Footer?

#if os(watchOS)
	@Environment(\._ignoreLayoutMargin)
	private var ignoreLayoutMargin
#else
	@Environment(\.defaultListSectionSpacing)
	private var defaultListSectionSpacing
#endif

	init(_ titleKey: LocalizedStringKey,
		 background backgroundStyle: MASectionBackgroundStyle? = nil,
		 @ViewBuilder content: () -> Content) where Footer == Never {
#if os(watchOS)
		self.backgroundStyle = backgroundStyle ?? .separatedInsetGrouped
#else
		self.backgroundStyle = backgroundStyle ?? .insetGrouped
#endif
		self.header = MASectionHeader(titleKey)
		self.content = content()
		self.footer = Never?.none
	}

#if os(watchOS)
	init(_ titleKey: LocalizedStringKey,
		 footer footerKey: LocalizedStringKey,
		 background backgroundStyle: MASectionBackgroundStyle? = nil,
		 @ViewBuilder content: () -> Content) where Footer == Text {
		self.backgroundStyle = backgroundStyle ?? .separatedInsetGrouped
		self.header = MASectionHeader(titleKey)
		self.content = content()
		self.footer = Text(footerKey)
	}
#else
	init(_ titleKey: LocalizedStringKey,
		 footer footerKey: LocalizedStringKey,
		 background backgroundStyle: MASectionBackgroundStyle? = nil,
		 @ViewBuilder content: () -> Content) where Footer == MASectionFooter {
		self.backgroundStyle = backgroundStyle ?? .insetGrouped
		self.header = MASectionHeader(titleKey)
		self.content = content()
		self.footer = MASectionFooter(footerKey)
	}
#endif
	init(_ titleKey: LocalizedStringKey,
		 background backgroundStyle: MASectionBackgroundStyle? = nil,
		 @ViewBuilder content: () -> Content,
		 @ViewBuilder footer: () -> Footer) {
#if os(watchOS)
		self.backgroundStyle = backgroundStyle ?? .separatedInsetGrouped
#else
		self.backgroundStyle = backgroundStyle ?? .insetGrouped
#endif
		self.header = MASectionHeader(titleKey)
		self.content = content()
		self.footer = footer()
	}

	var body: some View {
#if os(watchOS)
		switch backgroundStyle {
		case .none:
			content
		case .separatedInsetGrouped:
			Section {
				content
			} header: {
				header
			} footer: {
				footer
			}
			.listRowInsets(ignoreLayoutMargin ? .zero : nil)
		}
#else
		MAFormMetricsBuilder { metrics in
			header

			switch backgroundStyle {
			case .none:
				MAFormNoBackground(metrics) {
					content
				}
			case .insetGrouped:
				MAFormRoundedBackground(metrics) {
					content
				}
			case .separatedInsetGrouped:
				MAFormSeparatedRoundedBackground(metrics) {
					content
				}
			}

			ZStack(alignment: .topLeading) {
				Color.clear.frame(height: defaultListSectionSpacing)
				footer
			}
		}
#if os(macOS)
		.environment(\.horizontalLayoutMargin, MAFormMetrics.horizontalRowInset)
#endif
#endif
	}
}
