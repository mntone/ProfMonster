import SwiftUI

#if os(iOS)
import SwiftUIIntrospect
#endif

@available(macOS 13.0, *)
@available(watchOS, unavailable)
struct ColumnSettingsContainer: View {
#if os(macOS)
	@Environment(\.dismiss)
	private var dismiss

	@State
	private var viewModel = SettingsViewModel()

	@State
	private var selectedSettingsPane: SettingsPane = .display
#else
	let viewModel: SettingsViewModel

	@Binding
	var selectedSettingsPane: SettingsPane?

	init(viewModel: SettingsViewModel,
		 selection selectedSettingsPane: Binding<SettingsPane?>) {
		self.viewModel = viewModel
		self._selectedSettingsPane = selectedSettingsPane
	}
#endif

	var body: some View {
		if #available(iOS 16.0, *) {
			NavigationSplitView(columnVisibility: .constant(.all)) {
				List(SettingsPane.allCases, id: \.self, selection: $selectedSettingsPane) { pane in
					pane.label
				}
#if os(macOS)
				.navigationSplitViewColumnWidth(215.0)
#else
				.listStyle(.insetGrouped)
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
				.modifier(SharedSettingsContainerModifier())
			} detail: {
				NavigationStack {
#if os(macOS)
					selectedSettingsPane.view(viewModel)
						.buttonStyle(.link)
#else
					selectedSettingsPane?.view(viewModel)
#endif
				}
				.formStyle(.grouped)
			}
			.navigationSplitViewStyle(.balanced)
#if os(macOS)
			.onExitCommand(perform: dismiss.callAsFunction)
			.frame(width: 720)
#else
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
					SelectableInsetGroupedListRowBackport(tag: pane, selection: $selectedSettingsPane) {
						pane.label
					}
				}
				.listStyle(.insetGrouped)
				.modifier(SharedSettingsContainerModifier())

				selectedSettingsPane?.view(viewModel)
			}
			.navigationViewStyle(.columns)
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
	let viewModel = SettingsViewModel()
	return ColumnSettingsContainer(viewModel: viewModel, selection: .constant(.display))
#endif
}
