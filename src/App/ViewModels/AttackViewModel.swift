import Foundation
import MonsterAnalyzerCore
import SwiftUI

protocol AttackItemViewModel {
	var attack: Attack { get }
}

extension AttackItemViewModel {
	var attackColor: Color {
		switch attack {
		case .slash, .strike, .shell:
			return .primary
		case .fire:
			return .fire
		case .water:
			return .water
		case .thunder:
			return .thunder
		case .ice:
			return .ice
		case .dragon:
			return .dragon
		}
	}

	var attackIcon: Image {
		switch attack {
		case .slash:
			return Image(systemName: "scissors")
		case .strike:
			return Image(systemName: "hammer.fill")
		case .shell:
			return Image(systemName: "fossil.shell.fill")
		case .fire:
			return Image(systemName: "flame.fill")
		case .water:
			return Image(systemName: "drop.fill")
		case .thunder:
			return Image(systemName: "bolt.fill")
		case .ice:
			return Image(systemName: "snowflake")
		case .dragon:
			return Image(systemName: "atom")
		}
	}

	var attackKey: LocalizedStringKey {
		LocalizedStringKey("label.attack." + attack.rawValue)
	}
}
