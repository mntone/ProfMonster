import SwiftUI

@available(iOS, introduced: 15.0, deprecated: 16.0, message: "Use native List instead")
@available(macOS, unavailable)
@available(watchOS, unavailable)
struct RoundedRectangleSelectableListRowBackport<Tag: Equatable, Content: View>: View {
	let tag: Tag
	let content: Content

	@Binding
	var selection: Tag

	@ScaledMetric(relativeTo: .body)
	private var verticalPadding: CGFloat = 11.0

	init(tag: Tag,
		 selection: Binding<Tag>,
		 @ViewBuilder content: () -> Content) {
		self.tag = tag
		self._selection = selection
		self.content = content()
	}

	var body: some View {
		let shape = RoundedRectangle(cornerRadius: 11.0)
		let isSelected = tag == selection
		content
			.foregroundStyle(isSelected ? .white : .primary)
			.padding(EdgeInsets(top: verticalPadding,
								leading: 8.0,
								bottom: verticalPadding,
								trailing: 8.0))
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
