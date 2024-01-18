import Foundation

struct PhysiologyMapperOptions {
	let mergeParts: Bool
}

struct PhysiologyMapper {
	private let _languageService: LanguageService

	init(languageService: LanguageService) {
		self._languageService = languageService
	}

	private func map(_ src: MHMonsterPhysiologyValue,
					 states: [String]? = nil) -> PhysiologyPart {
		let baseStates = states ?? src.states
		let statesLabel = _languageService.getLocalizedJoinedString(of: baseStates, for: .state)
		return PhysiologyPart(stateInfo: Self.getStateInfo(baseStates),
							  label: statesLabel,
							  value: PhysiologyValue(slash: src.slash,
													 impact: src.impact,
													 shot: src.shot,
													 fire: src.fire,
													 water: src.water,
													 thunder: src.thunder,
													 ice: src.ice,
													 dragon: src.dragon),
							  stun: src.stun)
	}

	private func getGroup(of targetState: String, from values: [MHMonsterPhysiologyValue]) -> [PhysiologyPart] {
		values.compactMap { value -> PhysiologyPart? in
			guard value.states.contains(targetState) else {
				return nil
			}
			var filteredState = value.states.filter { state in
				state != targetState
			}
			if filteredState.isEmpty {
				filteredState.append("default")
			}
			return map(value, states: filteredState)
		}
	}

	private func map(_ targetState: String, of physiologies: [MHMonsterPhysiology], merge: Bool) -> [PhysiologyParts] {
		if merge {
			var result: [PhysiologyParts] = []
			for physiology in physiologies {
				let abnormalItems = getGroup(of: targetState, from: physiology.values)
				guard !abnormalItems.isEmpty else {
					let partsLabel = _languageService.getLocalizedJoinedString(of: physiology.parts, for: .part)
					let defaultItems = getGroup(of: "default", from: physiology.values)
					let defaultGroup = PhysiologyParts(parts: physiology.parts,
													   label: partsLabel,
													   items: defaultItems,
													   isReference: true)
					result.append(defaultGroup)
					continue
				}

				if let matchedIndex = result.firstIndex(where: { group in
					group.items == abnormalItems
				}) {
					let targetGroup = result[matchedIndex]
					let mergedParts = targetGroup.parts + physiology.parts
					let mergedPartsLabel = _languageService.getLocalizedJoinedString(of: mergedParts, for: .part)
					let mergedGroup = PhysiologyParts(parts: mergedParts,
													  label: mergedPartsLabel,
													  items: targetGroup.items,
													  isReference: false)
					result[matchedIndex] = mergedGroup
					continue
				}

				let partsLabel = _languageService.getLocalizedJoinedString(of: physiology.parts, for: .part)
				let abnormalGroup = PhysiologyParts(parts: physiology.parts,
													label: partsLabel,
													items: abnormalItems,
													isReference: false)
				result.append(abnormalGroup)
			}

			// Replace the label with "all" if the number of items is 1.
			if result.count == 1 {
				let allLabel = _languageService.getLocalizedJoinedString(of: ["all"], for: .part)
				let allGroup = result[0]
				result[0] = PhysiologyParts(parts: allGroup.parts,
											label: allLabel,
											items: allGroup.items,
											isReference: allGroup.isReference)
			}
			return result
		} else {
			let result = physiologies.map { physiology in
				let abnormalItems = getGroup(of: targetState, from: physiology.values)
				let partsLabel = _languageService.getLocalizedJoinedString(of: physiology.parts, for: .part)
				guard !abnormalItems.isEmpty else {
					let defaultItems = getGroup(of: "default", from: physiology.values)
					return PhysiologyParts(parts: physiology.parts,
										   label: partsLabel,
										   items: defaultItems,
										   isReference: true)
				}
				return PhysiologyParts(parts: physiology.parts,
									   label: partsLabel,
									   items: abnormalItems,
									   isReference: false)
			}
			return result
		}
	}

	func map(json src: MHMonster, options: PhysiologyMapperOptions) -> Physiology {
		let allAbnormalStates = Set(src.physiologies.flatMap { physiologies in
			Set(physiologies.values.flatMap(\.states))
		}).subtracting(Self.removingState)
		let filteredAllAbnormalStates = Self.filter(allAbnormalStates, by: src.physiologies, in: 500000)

		let defaultSectionData = src.physiologies.map { physiology in
			let items = physiology.values.compactMap { physiologyValue -> PhysiologyPart? in
				guard !physiologyValue.states.contains(where: { s in filteredAllAbnormalStates.contains(s) }) else {
					return nil
				}
				return map(physiologyValue)
			}

			let partsLabel = _languageService.getLocalizedJoinedString(of: physiology.parts, for: .part)
			return PhysiologyParts(parts: physiology.parts,
								   label: partsLabel,
								   items: items,
								   isReference: false)
		}
		let defaultSection = PhysiologyStateGroup(key: "default",
												  label: _languageService.getLocalizedString(of: "default", for: .state),
												  groups: defaultSectionData,
												  average: Self.getAverages(defaultSectionData))

		var abnormalSections = filteredAllAbnormalStates.map { targetState in
			let sectionData = map(targetState, of: src.physiologies, merge: options.mergeParts)
			return PhysiologyStateGroup(key: targetState,
										label: _languageService.getLocalizedString(of: targetState, for: .state),
										groups: sectionData,
										average: Self.getAverages(sectionData))
		}
		abnormalSections.insert(defaultSection, at: 0)

		return Physiology(id: src.id, sections: abnormalSections)
	}


	private static let removingState: Set<String> = ["default", "broken"]

	private static func getStateInfo(_ states: [String]) -> PhysiologyStateInfo {
		if states.contains("broken") {
			return .broken
		} else if states.contains("default") {
			return .default
		} else {
			return .other
		}
	}

	private static func filter<C>(_ states: C, by physiologies: [MHMonsterPhysiology], in frequency10e6: Int) -> [String] where C: Collection, C.Element == String {
		return states.filter { state in
			let pickedCount = physiologies.reduce(into: 0) { count, physiology in
				let hasState = physiology.values.contains { value in
					value.states.contains(state)
				}
				if hasState {
					count += 1
				}
			}
			let output = 1000000 * pickedCount / physiologies.count >= frequency10e6
			return output
		}
	}

	private static func getAverage(_ data: [PhysiologyParts], of attack: Attack) -> PhysiologyStateGroup.AverageFloat {
		let sum = data.map { group in
			group.parts.count * group.items.map { physiology in
				Int(physiology.value.value(of: attack))
			}.reduce(into: 0) { cur, next in
				cur += next
			}
		}.reduce(into: 0) { cur, next in
			cur += next
		}

		let count = data.map { group in
			group.parts.count * group.items.count
		}.reduce(into: 0) { cur, next in
			cur += next
		}
		return PhysiologyStateGroup.AverageFloat(Float32(sum) / Float32(count))
	}

	private static func getAverages(_ data: [PhysiologyParts]) -> PhysiologyValue<PhysiologyStateGroup.AverageFloat> {
		PhysiologyValue(slash: Self.getAverage(data, of: .slash),
						impact: Self.getAverage(data, of: .impact),
						shot: Self.getAverage(data, of: .shot),
						fire: Self.getAverage(data, of: .fire),
						water: Self.getAverage(data, of: .water),
						thunder: Self.getAverage(data, of: .thunder),
						ice: Self.getAverage(data, of: .ice),
						dragon: Self.getAverage(data, of: .dragon))
	}
}
