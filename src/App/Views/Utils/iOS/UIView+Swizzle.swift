#if os(iOS)

import MonsterAnalyzerCore
import UIKit

extension UIView {
	static func swizzle(_ klass: AnyClass, from oldSelector: Selector, to newSelector: Selector) {
		guard let oldMethod = class_getInstanceMethod(klass, oldSelector),
			  let newMethod = class_getInstanceMethod(klass, newSelector) else {
			return
		}
		method_exchangeImplementations(oldMethod, newMethod)
	}

	@objc
	private func ma_didAddSubview(_ subview: UIView) {
		self.ma_didAddSubview(subview)

		var contentLayoutGuide: UILayoutGuide?
		var trailingBarGuide: UILayoutGuide?
		for layoutGuide in layoutGuides {
			if layoutGuide.identifier == "UINavigationBarItemContentLayoutGuide" {
				contentLayoutGuide = layoutGuide
			} else if layoutGuide.identifier.starts(with: "TrailingBarGuide") {
				trailingBarGuide = layoutGuide
			}
		}
		if let contentLayoutGuide, let trailingBarGuide {
			trailingBarGuide.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor).isActive = true
		}
	}

	static func swizzleNavigationBarContentView() {
		if #available(iOS 17.0, *) {
			// Nothing.
		} else if let klass = NSClassFromString("_UINavigationBarContentView") {
			swizzle(klass,
					from: #selector(UIView.didAddSubview(_:)),
					to: #selector(UIView.ma_didAddSubview(_:)))
		} else {
			MAApp.resolver.resolve(MonsterAnalyzerCore.Logger.self)?.notice("Failed to swizzle NavigationBarContentView")
		}
	}
}

#endif
