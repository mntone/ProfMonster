import SwiftUI

extension EdgeInsets {
	static var zero: EdgeInsets {
		EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
	}

	func setting(top: CGFloat) -> EdgeInsets {
		EdgeInsets(top: top,
				   leading: leading,
				   bottom: bottom,
				   trailing: trailing)
	}

	func setting(bottom: CGFloat) -> EdgeInsets {
		EdgeInsets(top: top,
				   leading: leading,
				   bottom: bottom,
				   trailing: trailing)
	}

	func setting(horizontal: CGFloat) -> EdgeInsets {
		EdgeInsets(top: top,
				   leading: horizontal,
				   bottom: bottom,
				   trailing: horizontal)
	}

	func setting(vertical: CGFloat) -> EdgeInsets {
		EdgeInsets(top: vertical,
				   leading: leading,
				   bottom: vertical,
				   trailing: trailing)
	}

	func adding(leading: CGFloat) -> EdgeInsets {
		EdgeInsets(top: top,
				   leading: self.leading + leading,
				   bottom: bottom,
				   trailing: trailing)
	}

	func adding(trailing: CGFloat) -> EdgeInsets {
		EdgeInsets(top: top,
				   leading: leading,
				   bottom: bottom,
				   trailing: self.trailing + trailing)
	}
}
