import Foundation

public enum Attack: String, CaseIterable {
	case slash
	case strike
	case shell

	case fire
	case water
	case thunder
	case ice
	case dragon

	public static let allElements: [Attack] = [.fire, .water, .thunder, .ice, .dragon]
}
