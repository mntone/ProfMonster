import SwiftUI

struct SettingsList<ItemView: View>: View {
	@ViewBuilder
	let content: (SettingsPane) -> ItemView

	var body: some View {
#if os(iOS)
		List(SettingsPane.allCases, rowContent: content)
#else
		Form {
			ForEach(SettingsPane.allCases, content: content)
		}
#endif
	}
}

@available(iOS 16.0, watchOS 9.0, *)
@available(macOS, unavailable)
struct DrillDownSettingsContainer: View {
	@Binding
	var selectedSettingsPanes: [SettingsPane]

	// watchOS 9 requires "dismiss" to be defined at this level.
	@Environment(\.dismiss)
	private var dismiss

#if os(iOS)
	@Environment(\.dynamicTypeSize)
	private var dynamicTypeSize

	@State
	private var isCloseButtonDisabled: Bool = false
#endif

	init(selection selectedSettingsPane: Binding<SettingsPane?>) {
		self._selectedSettingsPanes = Binding {
			selectedSettingsPane.wrappedValue.map { [$0] } ?? []
		} set: { value in
			switch value.count {
			case 0:
				selectedSettingsPane.wrappedValue = nil
			case 1:
				selectedSettingsPane.wrappedValue = value[0]
			default:
				fatalError()
			}
		}
	}

	var body: some View {
		NavigationStack(path: $selectedSettingsPanes) {
			SettingsList { pane in
				NavigationLink(value: pane) {
					pane.label
				}
#if os(iOS)
				.listRowInsetsLayoutMargin()
#endif
			}
			.navigationDestination(for: SettingsPane.self) { pane in
				pane.view
			}
			.navigationBarTitleDisplayMode(.large)
#if os(watchOS)
			.modifier(SharedSettingsContainerModifier(dismiss: dismiss.callAsFunction))
#else
			.modifier(SharedSettingsContainerModifier(dismiss: dismiss.callAsFunction,
													  isCloseButtonDisabled: isCloseButtonDisabled))
#endif
		}
#if os(watchOS)
		.block { content in
			if #available(watchOS 10.0, *) {
				content
			} else {
				// Hide the root navigation bar.
				// Require to show this navigation bar.
				content.navigationBarHidden(true)
			}
		}
#endif
#if os(iOS)
		.setCloseButtonDisabled($isCloseButtonDisabled)
		.block { content in
			switch dynamicTypeSize {
			case .xxLarge, .xxxLarge:
				content.listStyle(.grouped)
			default:
				content.listStyle(.insetGrouped)
			}
		}
#endif
	}
}

@available(macOS, unavailable)
struct DrillDownSettingsContainerBackport: View {
	@Binding
	var selectedSettingsPane: SettingsPane?

	@Environment(\.dismiss)
	private var dismiss

#if os(iOS)
	@Environment(\.dynamicTypeSize)
	private var dynamicTypeSize

	@State
	private var isCloseButtonDisabled: Bool = false
#endif

	init(selection selectedSettingsPane: Binding<SettingsPane?> = .constant(nil)) {
		self._selectedSettingsPane = selectedSettingsPane
	}

	var body: some View {
		NavigationView {
			SettingsList { pane in
				NavigationLink(tag: pane, selection: $selectedSettingsPane) {
					pane.view
				} label: {
					pane.label
				}
#if os(iOS)
				.listRowInsetsLayoutMargin()
#endif
			}
			.navigationBarTitleDisplayMode(.large)
#if os(watchOS)
			.modifier(SharedSettingsContainerModifier(dismiss: dismiss.callAsFunction))
#else
			.modifier(SharedSettingsContainerModifier(dismiss: dismiss.callAsFunction,
													  isCloseButtonDisabled: isCloseButtonDisabled))
#endif
		}
		// DO NOT WRITE FOLLOWING STYLE.
		// NavigationLink is disable by this style on watchOS 8.
		//.navigationViewStyle(.stack)
#if os(iOS)
		.navigationViewStyle(.stack)
		.setCloseButtonDisabled($isCloseButtonDisabled)
		.block { content in
			switch dynamicTypeSize {
			case .xxLarge, .xxxLarge:
				content.listStyle(.grouped)
			default:
				content.listStyle(.insetGrouped)
			}
		}
#endif
	}
}

@available(iOS 16.0, watchOS 9.0, *)
#Preview {
	return DrillDownSettingsContainer(selection: .constant(nil))
}
