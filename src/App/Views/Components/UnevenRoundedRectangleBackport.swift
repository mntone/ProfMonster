import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct UnevenRoundedRectangleBackport: Shape {
	struct CornerOptions: OptionSet {
		let rawValue: Int8

		static let topLeft     = CornerOptions(rawValue: 1 << 0)
		static let topRight    = CornerOptions(rawValue: 1 << 1)
		static let bottomLeft  = CornerOptions(rawValue: 1 << 2)
		static let bottomRight = CornerOptions(rawValue: 1 << 3)

		static let top: CornerOptions = [.topLeft, .topRight]
		static let bottom: CornerOptions = [.bottomLeft, .bottomRight]

		static let left: CornerOptions = [.topLeft, .bottomLeft]
		static let right: CornerOptions = [.topRight, .bottomRight]

		static let all: CornerOptions = [.topLeft, .topRight, .bottomLeft, .bottomRight]
	}

	private let cornerRadius: CGFloat
	private let corner: CornerOptions

	@available(iOS, introduced: 13.0, deprecated: 16.0, message: "use UnevenRoundedRectangle.init(topLeadingRadius:bottomLeadingRadius:bottomTrailingRadius:topTrailingRadius:style:)) instead")
	@available(macOS, introduced: 10.15, deprecated: 13.0, message: "use UnevenRoundedRectangle.init(topLeadingRadius:bottomLeadingRadius:bottomTrailingRadius:topTrailingRadius:style:)) instead")
	@available(tvOS, introduced: 13.0, deprecated: 16.0, message: "use UnevenRoundedRectangle.init(topLeadingRadius:bottomLeadingRadius:bottomTrailingRadius:topTrailingRadius:style:)) instead")
	@available(watchOS, introduced: 6.0, deprecated: 9.0, message: "use UnevenRoundedRectangle.init(topLeadingRadius:bottomLeadingRadius:bottomTrailingRadius:topTrailingRadius:style:)) instead")
	init(cornerRadius: CGFloat, corner: CornerOptions) {
		self.cornerRadius = cornerRadius
		self.corner = corner
	}

	func path(in rect: CGRect) -> Path {
		if corner.contains(.all) {
			return Path(rect)
		}

#if os(macOS)
		return Path { path in
			let cappedCornerRadius = min(cornerRadius, 0.5 * rect.width, 0.5 * rect.height)
			let halfPI: Angle = .radians(0.5 * .pi)
			if corner.contains(.topLeft) {
				path.move(to: CGPoint(x: cappedCornerRadius, y: 0))
			} else {
				path.move(to: CGPoint.zero)
			}

			let xCenter = rect.width - cappedCornerRadius
			if corner.contains(.topRight) {
				path.addLine(to: CGPoint(x: xCenter, y: 0))
				path.addArc(center: CGPoint(x: xCenter, y: cappedCornerRadius),
							radius: cappedCornerRadius,
							startAngle: -halfPI,
							endAngle: Angle.zero,
							clockwise: false)
			} else {
				path.addLine(to: CGPoint(x: rect.width, y: 0))
			}

			let yCenter = rect.height - cappedCornerRadius
			if corner.contains(.bottomRight) {
				path.addLine(to: CGPoint(x: rect.width, y: yCenter))
				path.addArc(center: CGPoint(x: xCenter, y: yCenter),
							radius: cappedCornerRadius,
							startAngle: Angle.zero,
							endAngle: halfPI,
							clockwise: false)
			} else {
				path.addLine(to: CGPoint(x: rect.width, y: rect.height))
			}

			if corner.contains(.bottomLeft) {
				path.addLine(to: CGPoint(x: cappedCornerRadius, y: rect.height))
				path.addArc(center: CGPoint(x: cappedCornerRadius, y: yCenter),
							radius: cappedCornerRadius,
							startAngle: halfPI,
							endAngle: Angle.radians(.pi),
							clockwise: false)
			} else {
				path.addLine(to: CGPoint(x: 0, y: rect.height))
			}

			if corner.contains(.topLeft) {
				path.addLine(to: CGPoint(x: 0, y: cappedCornerRadius))
				path.addArc(center: CGPoint(x: cappedCornerRadius, y: cappedCornerRadius),
							radius: cappedCornerRadius,
							startAngle: Angle.radians(.pi),
							endAngle: Angle.radians(1.5 * .pi),
							clockwise: false)
			} else {
				path.addLine(to: .zero)
			}
		}
#else
		var uiCorners: UIRectCorner = []
		if corner.contains(.topLeft) {
			uiCorners.insert(.topLeft)
		}
		if corner.contains(.topRight) {
			uiCorners.insert(.topRight)
		}
		if corner.contains(.bottomLeft) {
			uiCorners.insert(.bottomLeft)
		}
		if corner.contains(.bottomRight) {
			uiCorners.insert(.bottomRight)
		}
		let path = UIBezierPath(roundedRect: rect,
								byRoundingCorners: uiCorners,
								cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
		return Path(path.cgPath)
#endif
	}
}
