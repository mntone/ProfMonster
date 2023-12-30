import SwiftUI

struct ToolbarItemBackportModifier<Item: View>: ViewModifier {
	let alignment: HorizontalAlignment
	let item: Item

	func body(content: Content) -> some View {
#if os(macOS)
		content.toolbar {
			ToolbarItem(placement: .primaryAction) {
				item
			}
		}
#elseif os(watchOS)
		if #available(watchOS 10.0, *) {
			content.toolbar {
				ToolbarItem(placement: placement) {
					item
				}
			}
		} else {
			ZStack(alignment: stackPlacement) {
				content.bottomCircularButtonSafeAreaInsetAdjust()
				item.buttonStyle(.bottomCircular(alignment))
			}
			.ignoresSafeArea(.all, edges: .bottom)
		}
#else
		content.toolbar {
			ToolbarItem(placement: placement) {
				item
			}
		}
#endif
	}

	@available(macOS, unavailable)
	@available(watchOS 10.0, *)
	private var placement: ToolbarItemPlacement {
		switch alignment {
		case .leading:
			return .topBarLeading
		case .center:
			return .primaryAction
		case .trailing:
			return .topBarTrailing
		default:
			fatalError()
		}
	}

	@available(iOS, unavailable)
	@available(macOS, unavailable)
	@available(watchOS, deprecated: 10.0)
	private var stackPlacement: Alignment {
		switch alignment {
		case .leading:
			return .bottomLeading
		case .center:
			return .bottom
		case .trailing:
			return .bottomTrailing
		default:
			fatalError()
		}
	}
}

extension View {
	@ViewBuilder
	func toolbarItemBackport<Item: View>(alignment: HorizontalAlignment, @ViewBuilder item: () -> Item) -> ModifiedContent<Self, ToolbarItemBackportModifier<Item>> {
		modifier(ToolbarItemBackportModifier(alignment: alignment, item: item()))
	}
}
