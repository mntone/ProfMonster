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

#if !os(watchOS)
	@Environment(\.defaultListRowSpacing)
	private var defaultListRowSpacing

	@Environment(\.defaultListSectionSpacing)
	private var defaultListSectionSpacing

	@Environment(\.defaultMinListRowHeight)
	private var defaultMinListRowHeight

	@Environment(\.horizontalLayoutMargin)
	private var horizontalLayoutMargin

	@Environment(\._ignoreLayoutMargin)
	private var ignoreLayoutMargin
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
		Section {
			switch backgroundStyle {
			case .none:
				content
					.listRowBackground(EmptyView())
					.listRowInsets(.zero)
			case .separatedInsetGrouped:
				content
			}
		} header: {
			header
		} footer: {
			footer
		}
#else
#if os(macOS)
		let metrics = MAFormLayoutMetrics(layoutMargin: ignoreLayoutMargin ? 0.0 : MAFormMetrics.horizontalRowInset,
										  minRowHeight: defaultMinListRowHeight,
										  rowSpacing: defaultListRowSpacing,
										  sectionSpacing: defaultListSectionSpacing)
#else
		let metrics = MAFormLayoutMetrics(layoutMargin: ignoreLayoutMargin ? 0.0 : horizontalLayoutMargin,
										  minRowHeight: defaultMinListRowHeight,
										  rowSpacing: defaultListRowSpacing,
										  sectionSpacing: defaultListSectionSpacing)
#endif
		switch backgroundStyle {
		case .none:
			Group {
				header
				MAFormNoBackground(metrics, footer: footer) {
					content.environment(\.horizontalLayoutMargin, 0)
				}
			}
#if os(macOS)
			.environment(\.horizontalLayoutMargin, MAFormMetrics.horizontalRowInset)
#endif
		case .insetGrouped:
			Group {
				header
				MAFormRoundedBackground(metrics, footer: footer) {
					content
				}
			}
#if os(macOS)
			.environment(\.horizontalLayoutMargin, MAFormMetrics.horizontalRowInset)
#endif
		case .separatedInsetGrouped:

			Group {
				header
				MAFormSeparatedRoundedBackground(metrics, footer: footer) {
					content
				}
			}
#if os(macOS)
			.environment(\.horizontalLayoutMargin, MAFormMetrics.horizontalRowInset)
#endif
		}
#endif
	}
}
