import enum MonsterAnalyzerCore.AppUtil
import SwiftUI

#if os(iOS)
import SwiftUIIntrospect
#endif

struct DataSettingsPane: View {
	@StateObject
	private var viewModel = DataSettingsViewModel()

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
			Section {
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
#endif
					.textInputAutocapitalization(.never)
#if !os(watchOS)
					.focused($isActive)
#endif
#if os(iOS)
					.introspect(.textField, on: .iOS(.v15, .v16, .v17)) { textField in
						textField.clearButtonMode = .whileEditing
					}
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
				if isEditMode {
					Text("If there is a problem with the reference data, Prof. Monster may crash.")
				}
			}

			if !isEditMode {
				Section {
					ResetSettingsButton(viewModel: viewModel)
					ResetCacheButton(viewModel: viewModel)
				} footer: {
					if let storageSize = viewModel.storageSize {
						Text("Cache Size: \(storageSize)")
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
		.interactiveDismissDisabled(isEditMode)
#if os(macOS)
		.block { content in
			if #available(macOS 13.0, *) {
				content.navigationBarBackButtonHidden(isActive)
			} else {
				content
			}
		}
#else
		.navigationBarBackButtonHidden(isEditMode)
#endif
		.navigationTitle("Data")
		.modifier(SharedSettingsPaneModifier())
		.task {
			await viewModel.updateStorageSize()
		}
	}
}
