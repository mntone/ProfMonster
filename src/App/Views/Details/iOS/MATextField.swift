import SwiftUI

struct MATextField: UIViewRepresentable {
	let enableDoneButton: Bool

	@Binding
	private(set) var text: String

	@Binding
	private(set) var isEditing: Bool

	func makeCoordinator() -> Coordinator {
		Coordinator(text: $text, isEditing: $isEditing)
	}

	func makeUIView(context: Context) -> UITextView {
		let textView: UITextView
		if #available(iOS 16.0, *) {
			textView = UITextView()
		} else {
			textView = _PatchedUITextView()
			textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
		}
		textView.adjustsFontForContentSizeCategory = true
		textView.backgroundColor = .secondarySystemGroupedBackground
		textView.contentInsetAdjustmentBehavior = .never
		textView.delegate = context.coordinator
		textView.font = .preferredFont(forTextStyle: .body)
		textView.isScrollEnabled = false

		if enableDoneButton {
			let accessoryViewFrame = CGRect(x: 0.0, y: 0.0, width: 320.0, height: 44.0)
			let accessoryView = NotesAccessoryView(frame: accessoryViewFrame)
			accessoryView.delegate = context.coordinator
			textView.inputAccessoryView = accessoryView
		}

		updateShared(textView, context: context)
		return textView
	}

	func updateUIView(_ textView: UITextView, context: Context) {
		updateShared(textView, context: context)
	}

	@available(iOS 16.0, *)
	func sizeThatFits(_ proposal: ProposedViewSize, uiView textView: UITextView, context: Context) -> CGSize? {
		var size = textView.systemLayoutSizeFitting(
			CGSize(width: proposal.width ?? UIView.layoutFittingCompressedSize.width,
				   height: UIView.layoutFittingCompressedSize.height),
			withHorizontalFittingPriority: .required,
			verticalFittingPriority: .defaultLow)
		if size.height < context.environment.defaultMinListRowHeight {
			size.height = context.environment.defaultMinListRowHeight
		}
		return proposal.replacingUnspecifiedDimensions(by: size)
	}

	private func updateShared(_ textView: UITextView, context: Context) {
		if textView.isUserInteractionEnabled != context.environment.isEnabled {
			textView.isUserInteractionEnabled = context.environment.isEnabled
		}
		if textView.text != text {
			textView.text = text
		}

		context.coordinator.text = $text
		context.coordinator.textView = textView
		context.coordinator.setEnvironmentValues(textView,
												 dynamicTypeSize: context.environment.dynamicTypeSize,
												 pixelLength: context.environment.pixelLength,
												 horizontalInsets: context.environment.horizontalLayoutMargin)

		if let patchedTextView = textView as? _PatchedUITextView {
			patchedTextView.minHeight = context.environment.defaultMinListRowHeight
		}
	}
}

extension MATextField {
	final class Coordinator: NSObject, UITextViewDelegate, NotesAccessoryViewDelegate {
		fileprivate var text: Binding<String>
		fileprivate var isEditing: Binding<Bool>
		fileprivate weak var textView: UITextView?

		private var savedDynamicTypeSize: DynamicTypeSize = .large
		private var savedPixelLength: CGFloat = 0.5
		private var savedHorizontalInsets: CGFloat = 0.0

		init(text: Binding<String>,
			 isEditing: Binding<Bool>) {
			self.text = text
			self.isEditing = isEditing
		}

		fileprivate func setEnvironmentValues(_ textView: UITextView,
											  dynamicTypeSize: DynamicTypeSize,
											  pixelLength: CGFloat,
											  horizontalInsets: CGFloat) {
			var changed = false
			if savedDynamicTypeSize != dynamicTypeSize {
				savedDynamicTypeSize = dynamicTypeSize
				changed = true
			}
			if savedPixelLength != pixelLength {
				savedPixelLength = pixelLength
				changed = true
			}
			if savedHorizontalInsets != horizontalInsets {
				savedHorizontalInsets = horizontalInsets
				changed = true
			}
			if changed {
				let verticalInsets = pixelLength * round(0.5 * textView.font!.lineHeight / pixelLength)
				let horizontalInsetsRemovingPadding = horizontalInsets - 5.0 /* lineFragmentPadding: 5.0 (default) */
				textView.textContainerInset = UIEdgeInsets(top: verticalInsets,
														   left: horizontalInsetsRemovingPadding,
														   bottom: verticalInsets,
														   right: horizontalInsetsRemovingPadding)
			}
		}

		func textViewDidChange(_ textView: UITextView) {
			text.wrappedValue = textView.text
		}

		func textViewDidBeginEditing(_ textView: UITextView) {
			DispatchQueue.main.async {
				self.isEditing.wrappedValue = true
			}
		}

		func textViewDidEndEditing(_ textView: UITextView) {
			DispatchQueue.main.async {
				self.isEditing.wrappedValue = false
			}
		}

		func doneButtonDidPressed(_ doneButton: UIButton) {
			textView?.endEditing(true)
		}
	}

	@available(iOS, deprecated: 16.0)
	private final class _PatchedUITextView: UITextView {
		fileprivate var minHeight: CGFloat = 0.0

		override var intrinsicContentSize: CGSize {
			var size = systemLayoutSizeFitting(
				CGSize(width: frame.size.width,
					   height: UIView.layoutFittingCompressedSize.height),
				withHorizontalFittingPriority: .required,
				verticalFittingPriority: .defaultLow)
			if size.height < minHeight {
				size.height = minHeight
			}
			return size
		}
	}
}
