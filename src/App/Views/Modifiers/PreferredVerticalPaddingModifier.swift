import SwiftUI

#if os(iOS)

@available(iOS, deprecated: 16.0)
@available(macOS, unavailable)
@available(watchOS, unavailable)
struct _PreferredVerticalPaddingModifier: ViewModifier {
	@ScaledMetric(relativeTo: .body)
	private var padding: CGFloat = 11.0

	func body(content: Content) -> some View {
		content.padding(.vertical, padding)
	}
}

// MARK: - Vertical Padding for List on iOS 16+
// This is an incorrect size for some Dynamic Type Sizes,
// which will be fixed in the future.

@available(macOS, unavailable)
@available(watchOS, unavailable)
struct _DifferentialPreferredVerticalPaddingModifier: ViewModifier {
	@Environment(\.dynamicTypeSize)
	private var dynamicTypeSize

	@ScaledMetric(relativeTo: .body)
	private var basePadding: CGFloat = 11.0

	func body(content: Content) -> some View {
		content.padding(.vertical, padding)
	}

	private var padding: CGFloat {
		switch dynamicTypeSize {
		case .accessibility1...:
			return basePadding - 11.0
		case .xxxLarge:
			return basePadding - 10.0
		default:
			return 0.0
		}
	}
}

// MARK: - Vertical Padding for ListStyle.plain on iOS 15

@available(iOS, deprecated: 16.0)
@available(macOS, unavailable)
@available(watchOS, unavailable)
struct _PlainDifferentialPreferredVerticalPaddingModifierBackport: ViewModifier {
	@ScaledMetric(relativeTo: .body)
	private var basePadding: CGFloat = 11.0

	func body(content: Content) -> some View {
		content
			.padding(.top, basePadding - 7.0)
			.padding(.bottom, basePadding - 6.0)
	}
}

// MARK: - Vertical Padding for ListStyle.insetGrouped on iOS 15

@available(iOS, deprecated: 16.0)
@available(macOS, unavailable)
@available(watchOS, unavailable)
struct _InsetGroupedDifferentialPreferredVerticalPaddingModifierBackport: ViewModifier {
	@ScaledMetric(relativeTo: .body)
	private var basePadding: CGFloat = 11.0

	func body(content: Content) -> some View {
		content.padding(.vertical, basePadding - 6.0)
	}
}

#endif

@available(watchOS, unavailable)
extension View {
	@inline(__always)
	@ViewBuilder
	func preferredVerticalPadding() -> some View {
#if os(macOS)
		padding(.vertical, 10.0)
#else
		modifier(_PreferredVerticalPaddingModifier())
#endif
	}

	@inline(__always)
	@ViewBuilder
	func insetGroupedDifferentialPreferredVerticalPadding() -> some View {
#if os(macOS)
		padding(.vertical, 10.0)
#else
		if #available(iOS 16.0, *) {
			modifier(_DifferentialPreferredVerticalPaddingModifier())
		} else {
			modifier(_InsetGroupedDifferentialPreferredVerticalPaddingModifierBackport())
		}
#endif
	}

#if os(iOS)

	@available(macOS, unavailable)
	@inline(__always)
	@ViewBuilder
	func plainDifferentialPreferredVerticalPadding() -> some View {
		if #available(iOS 16.0, *) {
			modifier(_DifferentialPreferredVerticalPaddingModifier())
		} else {
			modifier(_PlainDifferentialPreferredVerticalPaddingModifierBackport())
		}
	}

	@available(iOS 16.0, *)
	@available(macOS, unavailable)
	@inline(__always)
	@ViewBuilder
	func differentialPreferredVerticalPadding() -> some View {
		modifier(_DifferentialPreferredVerticalPaddingModifier())
	}

	@available(iOS, deprecated: 16.0)
	@available(macOS, unavailable)
	@inline(__always)
	func plainDifferentialPreferredVerticalPaddingBackport3() -> ModifiedContent<Self, _PlainDifferentialPreferredVerticalPaddingModifierBackport> {
		modifier(_PlainDifferentialPreferredVerticalPaddingModifierBackport())
	}

	@available(iOS, deprecated: 16.0)
	@available(macOS, unavailable)
	@inline(__always)
	func insetGroupedDifferentialPreferredVerticalPaddingBackport3() -> ModifiedContent<Self, _InsetGroupedDifferentialPreferredVerticalPaddingModifierBackport> {
		modifier(_InsetGroupedDifferentialPreferredVerticalPaddingModifierBackport())
	}

#endif
}
