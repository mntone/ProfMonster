import SwiftUI

enum WeaknessViewMetrics {
#if os(macOS)
	static let maxPhysicalContentWidth: CGFloat = 200
	static let maxItemWidth: CGFloat = 120
#else
	static let maxPhysicalContentWidth: CGFloat = 160
	static let maxItemWidth: CGFloat = 96
#endif

	static func getComplexNumberText(_ value: Float32, length: Int, baseSize: CGFloat, weight: Font.Weight) -> Text {
		let integerFont: Font = .system(size: baseSize, weight: weight, design: .rounded)
		let integerText: Text = Text(Int(value), format: .number).font(integerFont)

		let fractionFont: Font = .system(size: 0.666666 * baseSize, weight: weight, design: .rounded)
		let power: Float32 = pow(10, Float32(length))
		let frac = (power * value.truncatingRemainder(dividingBy: 1)).rounded()
		if frac == 0 {
			return integerText + Text(verbatim: "." + String(repeating: "0", count: length)).font(fractionFont)
		} else {
			return integerText + (Text(verbatim: ".") + Text(frac, format: .number.precision(.integerLength(length)))).font(fractionFont)
		}
	}
}
