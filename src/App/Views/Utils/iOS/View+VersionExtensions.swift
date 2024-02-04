import SwiftUI

extension View {
	var isiOS16OrLater: Bool {
		if #available(iOS 16.0, *) {
			true
		} else {
			false
		}
	}

	var isiOS17OrLater: Bool {
		if #available(iOS 17.0, *) {
			true
		} else {
			false
		}
	}
}
