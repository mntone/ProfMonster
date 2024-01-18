import SwiftUI

enum MASectionBackgroundStyle {
	case none(rowInsets: EdgeInsets?)

	@available(watchOS, unavailable)
	case insetGrouped(rowInsets: EdgeInsets?, sectionSpacing: CGFloat?)

	case separatedInsetGrouped(rowInsets: EdgeInsets?)
}

struct MASection<Content: View, Footer: View>: View {
	let backgroundStyle: MASectionBackgroundStyle
	let content: Content
	let header: Text
	let footer: Footer?

	init(_ titleKey: LocalizedStringKey,
		 background backgroundStyle: MASectionBackgroundStyle? = nil,
		 @ViewBuilder content: () -> Content) where Footer == Never {
#if os(watchOS)
		self.backgroundStyle = backgroundStyle ?? .none(rowInsets: nil)
#else
		self.backgroundStyle = backgroundStyle ?? .insetGrouped(rowInsets: nil, sectionSpacing: nil)
#endif
		self.header = Text(titleKey)
		self.content = content()
		self.footer = Never?.none
	}

	init(_ titleKey: LocalizedStringKey,
		 background backgroundStyle: MASectionBackgroundStyle? = nil,
		 @ViewBuilder content: () -> Content,
		 @ViewBuilder footer: () -> Footer) {
#if os(watchOS)
		self.backgroundStyle = backgroundStyle ?? .none(rowInsets: nil)
#else
		self.backgroundStyle = backgroundStyle ?? .insetGrouped(rowInsets: nil, sectionSpacing: nil)
#endif
		self.header = Text(titleKey)
		self.content = content()
		self.footer = footer()
	}

	var body: some View {
		Section {
#if os(watchOS)
			switch backgroundStyle {
			case .none(.none):
				content.listRowBackground(EmptyView())
			case let .none(.some(rowInsets)):
				content
					.listRowBackground(EmptyView())
					.listRowInsets(rowInsets)
			case .separatedInsetGrouped(.none):
				content
			case let .separatedInsetGrouped(.some(rowInsets)):
				content.listRowInsets(rowInsets)
			}
#else
			switch backgroundStyle {
			case .none(.none):
				MAFormNoBackground {
					content
				}
#if os(macOS)
				.environment(\.horizontalLayoutMargin, MAFormMetrics.horizontalRowInset)
#endif
			case let .none(.some(rowInsets)):
				MAFormNoBackground(rowInsets: rowInsets) {
					content
				}
				.environment(\.horizontalLayoutMargin, rowInsets.leading)
			case let .insetGrouped(rowInsets, sectionSpacing):
				MAFormRoundedBackground(rowInsets: rowInsets, sectionSpacing: sectionSpacing) {
					content
				}
#if os(macOS)
				.environment(\.horizontalLayoutMargin, rowInsets?.leading ?? MAFormMetrics.horizontalRowInset)
#endif
			case .separatedInsetGrouped(.none):
				MAFormSeparatedRoundedBackground {
					content
				}
#if os(macOS)
				.environment(\.horizontalLayoutMargin, MAFormMetrics.horizontalRowInset)
#endif
			case let .separatedInsetGrouped(.some(rowInsets)):
				MAFormSeparatedRoundedBackground(rowInsets: rowInsets) {
					content
				}
				.environment(\.horizontalLayoutMargin, rowInsets.leading)
			}
#endif
		} header: {
			MASectionHeader(header: header)
		} footer: {
			footer
#if os(macOS)
				.foregroundStyle(.secondary)
				.frame(maxWidth: .infinity, alignment: .trailing)
#endif

		}
	}
}
