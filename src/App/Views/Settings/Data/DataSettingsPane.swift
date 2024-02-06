import enum MonsterAnalyzerCore.AppUtil
import SwiftUI

#if os(iOS)
import SwiftUIIntrospect
#endif

struct DataSettingsPane: View {
	@StateObject
	private var viewModel = DataSettingsViewModel()

#if os(iOS)
	@Environment(\.horizontalLayoutMargin)
	private var horizontalLayoutMargin
#endif

#if !os(watchOS)
	@FocusState
	private var isActive: Bool
#endif

	private var isEditMode: Bool {
#if os(watchOS)
		viewModel.isSourceURLChanged
#else
		isActive
#endif
	}

	var body: some View {
		SettingsPreferredList {
			SettingsSection {
				TextField("Source URL",
						  text: $viewModel.sourceURLString,
						  prompt: Text(viewModel.currentURLString))
					.autocorrectionDisabled()
#if os(iOS)
					.keyboardType(.URL)
#endif
#if os(macOS)
					.block { content in
						if #available(macOS 14.0, *) {
							content.textContentType(.URL)
						} else {
							content
						}
					}
#else
					.textContentType(.URL)
					.textInputAutocapitalization(.never)
#endif
#if !os(watchOS)
					.focused($isActive)
#endif
#if os(iOS)
					.introspect(.textField, on: .iOS(.v15, .v16, .v17)) { textField in
						textField.clearButtonMode = .whileEditing
					}
					.preferredVerticalPadding()
#endif

#if os(macOS)
				if isActive {
					HStack {
						Spacer()

						Button("Cancel") {
							viewModel.cancel()
							isActive = false
						}

						Button("Save") {
							viewModel.save()
							isActive = false
						}
						.disabled(!viewModel.enableSaveButton)
					}
				}
#endif
			} header: {
				Text("Data Source")
			} footer: {
				Text("If there is a problem with the reference data, Prof. Monster may crash.")
					.opacity(isEditMode ? 1.0 : 0.0) // DO NOT USE `if`. It no longer works on iOS 15 & 16.
			}

			if !isEditMode {
				if let dataSourceInfo = viewModel.currentDataSourceInformation {
					SettingsSection("Data Source Info") {
						SettingsLabeledContent(LocalizedStringKey("Name"), value: dataSourceInfo.name)
						SettingsLabeledContent(LocalizedStringKey("Copyright"), value: dataSourceInfo.copyright)
						SettingsLabeledContent(LocalizedStringKey("License"), value: dataSourceInfo.license)
					}
#if os(watchOS)
					.listRowBackground(EmptyView())
#endif
				}

				SettingsSection {
					ResetSettingsButton(viewModel: viewModel)
					ResetCacheButton(viewModel: viewModel)
				} footer: {
					if let storageSize = viewModel.storageSize {
						Text("Cache Size: \(storageSize)")
#if os(macOS)
							.foregroundStyle(.secondary)
#endif
							.transition(.opacity)
					}
				}
				.animation(.default, value: viewModel.storageSize)
			}
		}
#if !os(macOS)
		.toolbar {
			ToolbarItem(placement: .confirmationAction) {
				if isEditMode {
					Button("Save") {
						viewModel.save()
#if !os(watchOS)
						isActive = false
#endif
					}
#if os(iOS)
					.padding(.trailing, isiOS17OrLater ? 0.0 : horizontalLayoutMargin)
#endif
					.disabled(!viewModel.enableSaveButton)
				}
			}

			ToolbarItem(placement: .cancellationAction) {
				if isEditMode {
#if os(watchOS)
					if #available(watchOS 10.0, *) {
						Button("Cancel", systemImage: "xmark") {
							viewModel.cancel()
						}
					} else {
						Button("Cancel") {
							viewModel.cancel()
						}
					}
#else
					Button("Cancel") {
						viewModel.cancel()
						isActive = false
					}
#endif
				}
			}
		}
#endif
#if !os(watchOS)
		.animation(.default, value: isActive)
#endif
#if os(iOS)
		.closeButtonDisabled(isActive)
#endif
		.interactiveDismissDisabled(isEditMode)
#if !os(macOS)
		.navigationBarBackButtonHidden(isEditMode)
#endif
		.navigationTitle("Data")
		.modifier(SharedSettingsPaneModifier())
		.task {
			await viewModel.updateStorageSize()
		}
	}
}
