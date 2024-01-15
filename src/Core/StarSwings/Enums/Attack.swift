import Foundation

public enum Attack: String, CaseIterable {
	case slash = "Slash"
	case impact = "Impact"
	case shot = "Shot"

	case fire = "Fire"
	case water = "Water"
	case thunder = "Thunder"
	case ice = "Ice"
	case dragon = "Dragon"

	public static let allElements: [Attack] = [.fire, .water, .thunder, .ice, .dragon]
}
