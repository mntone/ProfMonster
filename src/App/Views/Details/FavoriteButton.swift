import SwiftUI

#if os(watchOS)
import enum WatchKit.WKHapticType
import class WatchKit.WKInterfaceDevice
#endif

struct FavoriteButton: View {
	@Binding
	private(set) var favorite: Bool

	private var resources: (text: LocalizedStringKey, image: String) {
		let text: LocalizedStringKey, image: String
		if favorite {
			text = "Delete Favorite"
			image = "star.fill"
		} else {
			text = "Add to Favorites"
			image = "star"
		}
		return (text, image)
	}

	@ViewBuilder
	private var button: some View {
		let res = resources
		if #available(iOS 17.0, *) {
			Button(res.text, systemImage: res.image) {
				favorite.toggle()
			}
#if !os(watchOS)
			.help(res.text)
#endif
		} else {
			Button {
#if os(watchOS)
				WKInterfaceDevice.current().play(.click)
#endif
				favorite.toggle()
			} label: {
				Label(res.text, systemImage: res.image)
					.frame(height: 36)
					.padding(.leading, 8)
					.padding(.trailing)
			}
#if !os(watchOS)
			.help(res.text)
#endif
		}
	}

	var body: some View {
		button
			.animation(.easeInOut, value: favorite)
#if os(watchOS)
			.foregroundStyle(.yellow)
#else
#if os(iOS)
			.tint(.yellow)
#endif
			.keyboardShortcut("S", modifiers: .command)
#endif
	}
}
