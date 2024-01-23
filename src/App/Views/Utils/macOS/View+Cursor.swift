import SwiftUI

@available(macOS 10.15, *)
public enum Cursor {
	case `default`
	case arrow
	case pointingHand
	case openHand
	case closedHand

	fileprivate var nativeCursor: NSCursor {
		switch self {
		case .default:
			fatalError()
		case .arrow:
			NSCursor.arrow
		case .pointingHand:
			NSCursor.pointingHand
		case .openHand:
			NSCursor.openHand
		case .closedHand:
			NSCursor.closedHand
		}
	}
}

@available(macOS 10.15, *)
extension View {
	public func cursor(_ cursor: Cursor) -> some View {
		onChangeBackport(of: cursor, initial: true) { _, newValue in
			if newValue == .default {
				NSCursor.pop()
			} else {
				newValue.nativeCursor.push()
			}
		}
	}
}
