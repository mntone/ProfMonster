import SwiftUI

struct LicenseView: View {
	let name: String
	let link: URL?
	let text: String

	@State
	private(set) var isExpanded = false

#if os(macOS)
	@State
	private var isHovering = false
#endif

	var body: some View {
#if os(watchOS)
		NavigationLink {
			ScrollView {
				Text(verbatim: text)
					.font(.caption)
					.scenePadding()
			}
			.navigationTitle(Text(verbatim: name))
		} label: {
			Text(verbatim: name)
		}
#else
		DisclosureGroup(isExpanded: $isExpanded) {
			Text(verbatim: text)
				.font(.callout)
				.foregroundStyle(.secondary)
				.frame(maxWidth: .infinity, alignment: .leading)
#if os(macOS)
				.textSelection(.enabled)
				.block { content in
					if #available(macOS 13.0, *) {
						content.listRowSeparator(.hidden, edges: .top)
					} else {
						content
					}
				}
#else
				.listRowSeparator(.hidden, edges: .top)
#endif
		} label: {
#if os(macOS)
			if let link {
				Link(destination: link) {
					Text(verbatim: name)
				}
				.foregroundStyle(.primary)
				.cursor(isHovering ? .pointingHand : .default)
				.onHover { hovering in
					isHovering = hovering
				}
			} else {
				Text(verbatim: name)
			}
#else
			HStack {
				Text(verbatim: name)
				if let link {
					Link(destination: link) {
						Label("Open Browser", systemImage: "safari")
					}
					.buttonStyle(.borderless)
				}
			}
			.settingsPadding()
#endif
		}
#endif
	}
}

@available(macOS 13.0, *)
#Preview {
	Form {
		LicenseView(name: "Name", link: nil, text: "Text")
		LicenseView(name: "Name", link: nil, text: "Expanded Text", isExpanded: true)
	}
#if os(macOS)
	.formStyle(.grouped)
#endif
	.previewLayout(.sizeThatFits)
}
