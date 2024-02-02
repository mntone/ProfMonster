import SwiftUI

#if os(iOS)
import SwiftUIIntrospect
#endif

@available(macOS 13.0, *)
@available(watchOS, unavailable)
struct ColumnSettingsContainer: View {
	// iPadOS 15 requires "dismiss" to be defined at this level.
	@Environment(\.dismiss)
	private var dismiss

#if os(macOS)
	@State
	private var selectedSettingsPane: SettingsPane = .display
#else

	@Binding
	var selectedSettingsPane: SettingsPane?

	@State
	private var isCloseButtonDisabled: Bool = false

	init(selection selectedSettingsPane: Binding<SettingsPane?>) {
		self._selectedSettingsPane = selectedSettingsPane
	}
#endif

	var body: some View {
		if #available(iOS 16.0, *) {
			NavigationSplitView(columnVisibility: .constant(.all)) {
				List(SettingsPane.allCases, id: \.self, selection: $selectedSettingsPane) { pane in
					pane.label
#if os(iOS)
						.listRowInsetsLayoutMargin()
#endif
				}
#if os(macOS)
				.navigationSplitViewColumnWidth(215.0)
#else
				.listStyle(.insetGrouped)
				.disabled(isCloseButtonDisabled)
				.navigationBarTitleDisplayMode(.large)
#endif
				.block { content in
					if #available(iOS 17.0, macOS 14.0, *) {
						content.toolbar(removing: .sidebarToggle)
					} else {
#if os(macOS)
						if #available(macOS 13.0, *) {
							content.toolbar(.hidden, for: .windowToolbar)
						} else {
							content
						}
#else
						content
#endif
					}
				}
#if os(macOS)
				.modifier(SharedSettingsContainerModifier())
#else
				.modifier(SharedSettingsContainerModifier(dismiss: dismiss.callAsFunction,
														  isCloseButtonDisabled: isCloseButtonDisabled))
#endif
			} detail: {
				NavigationStack {
#if os(macOS)
					selectedSettingsPane.view
						.buttonStyle(.link)
#else
					selectedSettingsPane?.view
#endif
				}
				.formStyle(.grouped)
			}
			.navigationSplitViewStyle(.balanced)
#if os(macOS)
			.onExitCommand(perform: dismiss.callAsFunction)
			.frame(width: 720)
#else
			.setCloseButtonDisabled($isCloseButtonDisabled)
			.navigationBarTitleDisplayMode(.large)
			.introspect(.navigationSplitView, on: .iOS(.v16)) { splitViewController in
				splitViewController.displayModeButtonVisibility = .never
			}
			.onAppear {
				if selectedSettingsPane == nil {
					selectedSettingsPane = .display
				}
			}
#endif
		} else {
#if os(iOS)
			NavigationView {
				List(SettingsPane.allCases) { pane in
					SelectableListRowBackport(tag: pane, selection: $selectedSettingsPane) {
						pane.label.layoutMargin()
					}
				}
				.listStyle(.insetGrouped)
				.disabled(isCloseButtonDisabled)
				.modifier(SharedSettingsContainerModifier(dismiss: dismiss.callAsFunction,
														  isCloseButtonDisabled: isCloseButtonDisabled))

				selectedSettingsPane?.view
			}
			.navigationViewStyle(.columns)
			.setCloseButtonDisabled($isCloseButtonDisabled)
			.introspect(.navigationView(style: .columns), on: .iOS(.v15)) { splitViewController in
				splitViewController.displayModeButtonVisibility = .never
				splitViewController.preferredSplitBehavior = .displace
				splitViewController.preferredDisplayMode = .oneBesideSecondary
			}
			.onAppear {
				if selectedSettingsPane == nil {
					selectedSettingsPane = .display
				}
			}
#endif
		}
	}
}

@available(macOS 13.0, *)
#Preview {
#if os(macOS)
	return ColumnSettingsContainer()
#else
	return ColumnSettingsContainer(selection: .constant(.display))
#endif
}
