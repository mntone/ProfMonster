import Foundation

public enum Attack: String, CaseIterable {
	case slash = "Slash"
	case strike = "Strike"
	case shell = "Shell"

	case fire = "Fire"
	case water = "Water"
	case thunder = "Thunder"
	case ice = "Ice"
	case dragon = "Dragon"

	public static let allElements: [Attack] = [.fire, .water, .thunder, .ice, .dragon]
}
