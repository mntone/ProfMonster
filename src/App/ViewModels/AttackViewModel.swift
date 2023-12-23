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

	var attackImageName: String {
		switch attack {
		case .slash:
			return "scissors"
		case .strike:
			return "hammer.fill"
		case .shell:
			return "fossil.shell.fill"
		case .fire:
			return "flame.fill"
		case .water:
			return "drop.fill"
		case .thunder:
			return "bolt.fill"
		case .ice:
			return "snowflake"
		case .dragon:
			return "atom"
		}
	}

	var attackKey: LocalizedStringKey {
		LocalizedStringKey("label.attack." + attack.rawValue)
	}
}
