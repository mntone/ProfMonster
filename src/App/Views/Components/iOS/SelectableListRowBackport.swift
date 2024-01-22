import SwiftUI

#if os(iOS)

@available(iOS, introduced: 15.0, deprecated: 16.0, message: "Use native List instead")
@available(macOS, unavailable)
@available(watchOS, unavailable)
struct RoundedRectangleSelectableListRowBackport<Tag: Equatable, Content: View>: View {
	let tag: Tag
	let content: Content

	@Binding
	var selection: Tag

	init(tag: Tag,
		 selection: Binding<Tag>,
		 @ViewBuilder content: () -> Content) {
		self.tag = tag
		self._selection = selection
		self.content = content()
	}

	var body: some View {
		let shape = RoundedRectangle(cornerRadius: 8)
		let isSelected = tag == selection
		content
			.foregroundStyle(isSelected ? .white : .primary)
			.layoutMargin()
			.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
			.background(isSelected ? Color.accentColor : .clear, in: shape)
			.contentShape(shape) // Fix tap area
			.listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
			.onTapGesture {
				if selection != tag {
					selection = tag
				}
			}
	}
}

@available(iOS, introduced: 15.0, deprecated: 16.0, message: "Use native List instead")
@available(macOS, unavailable)
@available(watchOS, unavailable)
struct SelectableListRowBackport<Tag: Equatable, Content: View>: View {
	let tag: Tag
	let content: Content

	@Binding
	var selection: Tag

	init(tag: Tag,
		 selection: Binding<Tag>,
		 @ViewBuilder content: () -> Content) {
		self.tag = tag
		self._selection = selection
		self.content = content()
	}

	var body: some View {
		let isSelected = tag == selection
		content
			.foregroundStyle(isSelected ? .white : .primary)
			.layoutMargin()
			.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
			.background(isSelected ? Color.accentColor : .clear)
			.contentShape(Rectangle()) // Fix tap area
			.listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
			.onTapGesture {
				if selection != tag {
					selection = tag
				}
			}
	}
}

#endif
