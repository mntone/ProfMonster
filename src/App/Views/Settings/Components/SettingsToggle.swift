import SwiftUI

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct _ToggleLabeledContentStyle: LabeledContentStyle {
	@ScaledMetric(relativeTo: .body)
	private var verticalPadding: CGFloat = 11.0

	@ViewBuilder
	func makeBody(configuration: Configuration) -> some View {
		HStack(spacing: 0) {
			configuration.label
				.padding(EdgeInsets(top: verticalPadding,
									leading: 0.0,
									bottom: verticalPadding,
									trailing: 0.0))

			Spacer(minLength: 8.0)

			configuration.content.foregroundStyle(.secondary)
		}
	}
}

struct SettingsToggle: View {
#if os(iOS)
	@ScaledMetric(relativeTo: .body)
	private var verticalPadding: CGFloat = 11.0
#endif

	let content: Toggle<Text>

	init(_ titleKey: LocalizedStringKey, isOn: Binding<Bool>) {
		self.content = Toggle(titleKey, isOn: isOn)
	}

	init<S>(verbatim title: S, isOn: Binding<Bool>) where S: StringProtocol {
		self.content = Toggle.init(title, isOn: isOn)
	}

	var body: some View {
#if os(iOS)
		if #available(iOS 16.0, *) {
			content.labeledContentStyle(_ToggleLabeledContentStyle())
		} else {
			content
		}
#else
		content
#endif
	}
}
