import enum MonsterAnalyzerCore.Physical
import struct MonsterAnalyzerCore.PhysiologyStateGroup
import SwiftUI

struct PhysicalWeaknessItemViewModel: Identifiable {
	static let separator: String = {
		String(localized: "/")
	}()

	let id: String
	let firstPartNames: String
	let secondPartNames: String

	init(id: String,
		 first: String,
		 second: String) {
		self.id = id
		self.firstPartNames = first
		self.secondPartNames = second
	}

	init(prefixID: String,
		 physical: Physical,
		 stateGroup: PhysiologyStateGroup) {
		self.id = "\(prefixID):\(physical.prefix)"

		let aggregate = stateGroup.parts
			.flatMap { part in
				part.items
					.filter { $0.isDefault }
					.map { item in
						(partLabel: part.label,
						 value: item.value.value(of: physical))
					}
			}
			.sorted { a, b in
				a.value > b.value
			}
		guard let firstItem = aggregate.first,
			  firstItem.value >= 45 else {
			self.firstPartNames = ""
			self.secondPartNames = ""
			return
		}
		self.firstPartNames = aggregate
			.filter { $0.value == firstItem.value }
			.map(\.partLabel)
			.joined(separator: Self.separator)

		guard let secondItem = aggregate.first(where: { $0.value != firstItem.value }),
			  secondItem.value >= 45 else {
			self.secondPartNames = ""
			return
		}
		self.secondPartNames = aggregate
			.filter { $0.value == secondItem.value }
			.map(\.partLabel)
			.joined(separator: Self.separator)
	}
}
