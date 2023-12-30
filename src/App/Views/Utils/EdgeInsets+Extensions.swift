import SwiftUI

extension EdgeInsets {
	@inline(__always)
	static var zero: EdgeInsets {
		EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
	}

	@inline(__always)
	func setting(top: CGFloat) -> EdgeInsets {
		EdgeInsets(top: top,
				   leading: leading,
				   bottom: bottom,
				   trailing: trailing)
	}

	@inline(__always)
	func setting(bottom: CGFloat) -> EdgeInsets {
		EdgeInsets(top: top,
				   leading: leading,
				   bottom: bottom,
				   trailing: trailing)
	}

	@inline(__always)
	func setting(leading: CGFloat) -> EdgeInsets {
		EdgeInsets(top: top,
				   leading: leading,
				   bottom: bottom,
				   trailing: trailing)
	}

	@inline(__always)
	func setting(trailing: CGFloat) -> EdgeInsets {
		EdgeInsets(top: top,
				   leading: leading,
				   bottom: bottom,
				   trailing: trailing)
	}

	@inline(__always)
	func setting(horizontal: CGFloat) -> EdgeInsets {
		EdgeInsets(top: top,
				   leading: horizontal,
				   bottom: bottom,
				   trailing: horizontal)
	}

	@inline(__always)
	func setting(vertical: CGFloat) -> EdgeInsets {
		EdgeInsets(top: vertical,
				   leading: leading,
				   bottom: vertical,
				   trailing: trailing)
	}

	@inline(__always)
	func adding(leading: CGFloat) -> EdgeInsets {
		EdgeInsets(top: top,
				   leading: self.leading + leading,
				   bottom: bottom,
				   trailing: trailing)
	}

	@inline(__always)
	func adding(trailing: CGFloat) -> EdgeInsets {
		EdgeInsets(top: top,
				   leading: leading,
				   bottom: bottom,
				   trailing: self.trailing + trailing)
	}
}
