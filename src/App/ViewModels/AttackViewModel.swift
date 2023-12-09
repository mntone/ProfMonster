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
			return .red
		case .water:
			return .blue
		case .thunder:
			return .yellow
		case .ice:
			return .init(hue: 0.6, saturation: 1, brightness: 0.9)
		case .dragon:
			return .purple
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

protocol AttackViewModel where ItemType: AttackItemViewModel {
	associatedtype ItemType

	var items: [ItemType] { get }
}

extension AttackViewModel {
	subscript(attack: Attack) -> AttackItemViewModel? {
		items.first(where: { item in item.attack == attack })
	}
}
