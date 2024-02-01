import UIKit

protocol NotesAccessoryViewDelegate: AnyObject {
	func doneButtonDidPressed(_ doneButton: UIButton)
}

final class NotesAccessoryView: UIInputView {
	private weak var doneButton: UIButton?

	weak var delegate: NotesAccessoryViewDelegate?

	override var intrinsicContentSize: CGSize {
		var size = bounds.size
		size.height = Self.getHeight(verticalSizeClass: traitCollection.verticalSizeClass) + safeAreaInsets.bottom
		return size
	}

	init(frame: CGRect) {
		super.init(frame: frame, inputViewStyle: .keyboard)
		commonInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		commonInit()
	}

	private func commonInit() {
		translatesAutoresizingMaskIntoConstraints = false

		let doneButton = UIButton(type: .system)
		doneButton.autoresizingMask = .flexibleLeftMargin
		doneButton.setTitle(String(localized: "Done"), for: .normal)
		doneButton.addTarget(self, action: #selector(doneButtonDidPressed(_:)), for: .touchUpInside)
		addSubview(doneButton)

		self.doneButton = doneButton
		updateFont(traitCollection)
	}

	override func layoutMarginsDidChange() {
		super.layoutMarginsDidChange()
		updateSize(traitCollection)
	}

	override func safeAreaInsetsDidChange() {
		super.safeAreaInsetsDidChange()

		invalidateIntrinsicContentSize()
		updateSize(traitCollection)
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		let traitCollection = self.traitCollection
		if previousTraitCollection?.verticalSizeClass != traitCollection.verticalSizeClass {
			updateFont(traitCollection)
		} else if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
			updateFont(traitCollection)
		}
	}

	private func updateFont(_ traitCollection: UITraitCollection) {
		if let doneButton {
			let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body, compatibleWith: traitCollection)
				.withSymbolicTraits(.traitBold)!
			let font = UIFont(descriptor: descriptor,
							  size: max(17.0 /* .large for body */, min(descriptor.pointSize, 21.0 /* .xxLarge for body */)))
			doneButton.titleLabel!.font = font

			doneButton.sizeToFit()
			updateSize(traitCollection)
		}
	}

	private func updateSize(_ traitCollection: UITraitCollection) {
		guard let doneButton else { return }
		let viewFrame = frame
		let doneFrame = doneButton.frame
		let trailing = viewFrame.size.width - layoutMargins.right
		let height = Self.getHeight(verticalSizeClass: traitCollection.verticalSizeClass)
		doneButton.frame = CGRect(x: trailing - doneFrame.size.width,
								  y: doneFrame.origin.y,
								  width: doneFrame.size.width,
								  height: height)
	}

	@objc
	private func doneButtonDidPressed(_ doneButton: UIButton) {
		delegate?.doneButtonDidPressed(doneButton)
	}

	private static func getHeight(verticalSizeClass: UIUserInterfaceSizeClass) -> CGFloat {
		verticalSizeClass == .compact ? 36.0 : 44.0
	}
}
