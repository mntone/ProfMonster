import SwiftUI

struct LeadingToolbarItemBackportModifier<Item: View>: ViewModifier {
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
				ToolbarItem(placement: .topBarLeading) {
					item
				}
			}
		} else {
			ZStack(alignment: .bottomLeading) {
				content.bottomCircularButtonSafeAreaInsetAdjust()
				item.buttonStyle(.bottomCircular(.leading))
			}.ignoresSafeArea(.all, edges: .bottom)
		}
#else
		content.toolbar {
			ToolbarItem(placement: .topBarLeading) {
				item
			}
		}
#endif
	}
}

extension View {
	@ViewBuilder
	func leadingToolbarItemBackport<Item: View>(@ViewBuilder item: () -> Item) -> ModifiedContent<Self, LeadingToolbarItemBackportModifier<Item>> {
		modifier(LeadingToolbarItemBackportModifier(item: item()))
	}
}
