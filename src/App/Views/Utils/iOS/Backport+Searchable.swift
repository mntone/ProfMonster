import SwiftUI

#if os(iOS) || os(macOS)
@_spi(Advanced) import SwiftUIIntrospect
#endif

#if os(iOS)

import UIKit

private final class _SearchBarManager: NSObject, ObservableObject, UISearchBarDelegate {
	private var next: UISearchBarDelegate? = nil

	private weak var searchBar: UISearchBar? = nil

	@Published
	private(set) var isPresented: Bool = false

	func bindSearchBar(_ searchBar: UISearchBar) {
		if self != searchBar.delegate as? _SearchBarManager {
			self.next = searchBar.delegate

			searchBar.delegate = self
			self.searchBar = searchBar
		}
	}

	func unbindSearchBar() {
		if isPresented {
			isPresented = false
		}

		guard let searchBar else { return }
		self.searchBar = nil
		searchBar.delegate = next
	}

	func toggleState() {
		guard let searchBar else { return }

		if isPresented {
			searchBar.resignFirstResponder()
		} else {
			searchBar.becomeFirstResponder()
		}
	}

	func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
		next?.searchBarShouldBeginEditing?(searchBar) ?? true
	}

	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		next?.searchBarTextDidBeginEditing?(searchBar)
		isPresented = true
	}

	func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
		next?.searchBarShouldEndEditing?(searchBar) ?? true
	}

	func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
		next?.searchBarTextDidEndEditing?(searchBar)
		isPresented = false
	}

	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		next?.searchBar?(searchBar, textDidChange: searchText)
	}

	func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		next?.searchBar?(searchBar, shouldChangeTextIn: range, replacementText: text) ?? true
	}

	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		next?.searchBarSearchButtonClicked?(searchBar)
	}

	func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
		next?.searchBarBookmarkButtonClicked?(searchBar)
	}

	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		next?.searchBarCancelButtonClicked?(searchBar)
	}

	func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
		next?.searchBarResultsListButtonClicked?(searchBar)
	}

	func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
		next?.searchBar?(searchBar, selectedScopeButtonIndexDidChange: selectedScope)
	}
}

private struct _MobileSearchableModifier: ViewModifier {
	@Binding
	private(set) var isPresented: Bool

	@StateObject
	private var manager = _SearchBarManager()

	func body(content: Content) -> some View {
		content
			.introspect(.navigationView(style: .stack), on: .iOS(.v15), scope: .ancestor, customize: bind)
			.introspect(.navigationStack, on: .iOS(.v16), scope: .ancestor, customize: bind)
			.onChange(of: manager.isPresented) { presented in
				if isPresented != presented {
					isPresented = presented
				}
			}
			.onChange(of: isPresented) { presented in
				if manager.isPresented != presented {
					manager.toggleState()
				}
			}
			.onDisappear {
				manager.unbindSearchBar()
			}
	}

	private func bind(_ navigationController: UINavigationController) {
		guard let searchBar = navigationController.navigationBar.subviews.first(where: { $0 is UISearchBar }) as! UISearchBar? else {
			return
		}
		manager.bindSearchBar(searchBar)
	}
}

#endif

@available(iOS 15.0, *)
@available(macOS, unavailable)
@available(watchOS, unavailable)
extension Backport where Content: View {
	@inline(__always)
	@ViewBuilder
	public func searchable(text: Binding<String>, isPresented: Binding<Bool>) -> some View {
		if #available(iOS 17.0, macOS 14.0, *) {
			content.searchable(text: text, isPresented: isPresented)
		} else {
#if os(iOS)
			content
				.searchable(text: text)
				.modifier(_MobileSearchableModifier(isPresented: isPresented))
#else
			content
#endif
		}
	}

	@inline(__always)
	@ViewBuilder
	public func searchable(text: Binding<String>, isPresented: Binding<Bool>, prompt: LocalizedStringKey) -> some View {
		if #available(iOS 17.0, macOS 14.0, *) {
			content.searchable(text: text, isPresented: isPresented, prompt: prompt)
		} else {
#if os(iOS)
			content
				.searchable(text: text, prompt: prompt)
				.modifier(_MobileSearchableModifier(isPresented: isPresented))
#else
			content
#endif
		}
	}

	@inline(__always)
	@ViewBuilder
	public func searchable(text: Binding<String>, isPresented: Binding<Bool>, prompt: Text? = nil) -> some View {
		if #available(iOS 17.0, macOS 14.0, *) {
			content.searchable(text: text, isPresented: isPresented, prompt: prompt)
		} else {
#if os(iOS)
			content
				.searchable(text: text, prompt: prompt)
				.modifier(_MobileSearchableModifier(isPresented: isPresented))
#else
			content
#endif
		}
	}
}
