import Foundation

struct PhysiologyMapperOptions {
	let mergeParts: Bool
}

struct PhysiologyMapper {
	private let _languageService: LanguageService

	init(languageService: LanguageService) {
		self._languageService = languageService
	}

	private func mapPhysiologyValue(_ src: MHMonsterPhysiologyValue) -> PhysiologyValue<Int8> {
		PhysiologyValue(slash: src.slash,
						impact: src.impact,
						shot: src.shot,
						fire: src.fire,
						water: src.water,
						thunder: src.thunder,
						ice: src.ice,
						dragon: src.dragon)
	}

	private func mapPart(_ src: MHMonsterPhysiologyValue, override overrideStates: [String]? = nil) -> PhysiologyPart {
		let baseStates = overrideStates ?? src.states ?? ["default"]
		let statesLabel = _languageService.getLocalizedJoinedString(of: baseStates, for: .state)
		return PhysiologyPart(keys: src.states,
							  stateInfo: Self.getStateInfo(baseStates),
							  label: statesLabel,
							  value: mapPhysiologyValue(src),
							  stun: src.stun)
	}

	private func getDefaultPartData(from values: [MHMonsterPhysiologyValue], removing removingStates: [String]? = nil) -> [PhysiologyPart] {
		values.compactMap { value -> PhysiologyPart? in
			guard value.mode == nil else {
				return nil
			}

			if let removingStates,
			   let states = value.states,
			   states.contains(where: { s in removingStates.contains(s) }) {
				return nil
			} else {
				return mapPart(value)
			}
		}
	}

	private func getParentPartData(from values: [MHMonsterPhysiologyValue],
								   for targetState: String?,
								   removing removingStates: [String]? = nil) -> [PhysiologyPart] {
		guard targetState == "default" else {
			return getDefaultPartData(from: values, removing: removingStates)
		}
		return values.compactMap { value -> PhysiologyPart? in
			guard value.mode == nil else {
				return nil
			}

			if let targetState,
			   let states = value.states {
				if states.contains(targetState) {
					if let removingStates,
					   states.contains(where: { s in removingStates.contains(s) }) {
						return nil
					} else {
						return mapPart(value)
					}
				} else {
					return nil
				}
			} else {
				return nil
			}
		}
	}

	private func getPartData(from values: [MHMonsterPhysiologyValue], for targetState: String) -> [PhysiologyPart] {
		values.compactMap { value -> PhysiologyPart? in
			guard value.mode == nil,
				  let states = value.states,
				  states.contains(targetState) else {
				return nil
			}
			var filteredState = states.filter { state in
				state != targetState
			}
			if filteredState.isEmpty {
				filteredState.append("default")
			}
			return mapPart(value, override: filteredState)
		}
	}

	private func patchPartData(from values: [MHMonsterPhysiologyValue],
							   to data: inout [PhysiologyPart],
							   for mode: String?) {
		guard let mode else { return }

		for (i, item) in data.enumerated() {
			guard let modedData = values.first(where: { $0.mode == mode && $0.states == item.keys }) else {
				continue
			}

			let patchedItem = PhysiologyPart(keys: item.keys,
											 stateInfo: item.stateInfo,
											 label: item.label,
											 value: mapPhysiologyValue(modedData),
											 stun: modedData.stun)
			data[i] = patchedItem
		}
	}

	private func map(_ targetState: String,
					 of physiologies: [MHMonsterPhysiology],
					 for mode: String?,
					 states: [MHMonsterState]?,
					 merge: Bool) -> [PhysiologyParts] {
		if merge {
			var result: [PhysiologyParts] = []
			for physiology in physiologies {
				var abnormalItems = getPartData(from: physiology.values, for: targetState)
				guard !abnormalItems.isEmpty else {
					let partsLabel = _languageService.getLocalizedJoinedString(of: physiology.parts, for: .part)
					var defaultItems: [PhysiologyPart]
					if let parentState = states?.first(where: { $0.id == targetState }) {
						defaultItems = getParentPartData(from: physiology.values, for: parentState.parentState)
					} else {
						defaultItems = getDefaultPartData(from: physiology.values)
					}

					if !defaultItems.isEmpty {
						patchPartData(from: physiology.values, to: &defaultItems, for: mode)
						let defaultGroup = PhysiologyParts(keys: physiology.parts,
														   label: partsLabel,
														   items: defaultItems,
														   isReference: true)
						result.append(defaultGroup)
					}
					continue
				}
				patchPartData(from: physiology.values, to: &abnormalItems, for: mode)

				if let matchedIndex = result.firstIndex(where: { group in
					group.items == abnormalItems
				}) {
					let targetGroup = result[matchedIndex]
					let mergedParts = targetGroup.keys + physiology.parts
					let mergedPartsLabel = _languageService.getLocalizedJoinedString(of: mergedParts, for: .part)
					let mergedGroup = PhysiologyParts(keys: mergedParts,
													  label: mergedPartsLabel,
													  items: targetGroup.items,
													  isReference: false)
					result[matchedIndex] = mergedGroup
					continue
				}

				let partsLabel = _languageService.getLocalizedJoinedString(of: physiology.parts, for: .part)
				let abnormalGroup = PhysiologyParts(keys: physiology.parts,
													label: partsLabel,
													items: abnormalItems,
													isReference: false)
				result.append(abnormalGroup)
			}

			// Replace the label with "all" if the number of items is 1.
			if result.count == 1 {
				let allLabel = _languageService.getLocalizedJoinedString(of: ["all"], for: .part)
				let allGroup = result[0]
				result[0] = PhysiologyParts(keys: allGroup.keys,
											label: allLabel,
											items: allGroup.items,
											isReference: allGroup.isReference)
			}
			return result
		} else {
			let result = physiologies.compactMap { physiology -> PhysiologyParts? in
				var abnormalItems = getPartData(from: physiology.values, for: targetState)
				let partsLabel = _languageService.getLocalizedJoinedString(of: physiology.parts, for: .part)
				guard !abnormalItems.isEmpty else {
					var defaultItems: [PhysiologyPart]
					if let parentState = states?.first(where: { $0.id == targetState }) {
						defaultItems = getParentPartData(from: physiology.values, for: parentState.parentState)
					} else {
						defaultItems = getDefaultPartData(from: physiology.values)
					}

					guard !defaultItems.isEmpty else {
						return nil
					}
					patchPartData(from: physiology.values, to: &defaultItems, for: mode)
					return PhysiologyParts(keys: physiology.parts,
										   label: partsLabel,
										   items: defaultItems,
										   isReference: true)
				}
				patchPartData(from: physiology.values, to: &abnormalItems, for: mode)
				return PhysiologyParts(keys: physiology.parts,
									   label: partsLabel,
									   items: abnormalItems,
									   isReference: false)
			}
			return result
		}
	}

	private func map(_ src: MHMonster,
					 modeKey: String?,
					 mode: Mode,
					 options: PhysiologyMapperOptions) -> Physiology {
		let allAbnormalStates = Self.getAbnormalStates(src.physiologies)
		let filteredAllAbnormalStates = Self.filter(allAbnormalStates, by: src.physiologies, in: 500000)

		let defaultSectionData = src.physiologies.compactMap { physiology -> PhysiologyParts? in
			var items = getDefaultPartData(from: physiology.values, removing: filteredAllAbnormalStates)
			guard !items.isEmpty else { return nil }
			patchPartData(from: physiology.values, to: &items, for: modeKey)

			let partsLabel = _languageService.getLocalizedJoinedString(of: physiology.parts, for: .part)
			return PhysiologyParts(keys: physiology.parts,
								   label: partsLabel,
								   items: items,
								   isReference: false)
		}
		let defaultSection = PhysiologyStateGroup(key: "default",
												  label: _languageService.getLocalizedString(of: "default", for: .state),
												  parts: defaultSectionData,
												  average: Self.getAverages(defaultSectionData))

		var abnormalSections = filteredAllAbnormalStates.map { targetState in
			let sectionData = map(targetState, of: src.physiologies, for: modeKey, states: src.states, merge: options.mergeParts)
			return PhysiologyStateGroup(key: targetState,
										label: _languageService.getLocalizedString(of: targetState, for: .state),
										parts: sectionData,
										average: Self.getAverages(sectionData))
		}
		if !defaultSection.parts.isEmpty {
			abnormalSections.insert(defaultSection, at: 0)
		}

		return Physiology(id: "\(src.id):\(mode.rawValue)",
						  mode: mode,
						  states: abnormalSections)
	}

	func map(json src: MHMonster, options: PhysiologyMapperOptions) -> Physiologies {
		let modeKeys = Set(src.physiologies.flatMap { $0.values.compactMap(\.mode) })
		let modes = modeKeys.map { key in
			(key, Mode(rawValue: key))
		}
		let defaultMode = src.defaultMode.map(Mode.init(rawValue:))
		let modesData = [map(src, modeKey: nil, mode: defaultMode ?? .lowAndHigh, options: options)] + modes.map { key, mode in
			map(src, modeKey: key, mode: mode, options: options)
		}
		return Physiologies(id: src.id,
							version: src.version,
							modes: modesData)
	}

	private static let removingState: Set<String> = ["default", "broken"]

	private static func getAbnormalStates(_ physiologies: [MHMonsterPhysiology]) -> [String] {
		var uniqueStatesSet = Set<String>()
		let uniqueAbnormalStates = physiologies
			.flatMap { $0.values.compactMap(\.states).flatMap({ $0 }) }
			.filter { !removingState.contains($0) && uniqueStatesSet.insert($0).inserted }
		return uniqueAbnormalStates
	}

	private static func getStateInfo(_ states: [String]?) -> PhysiologyStateInfo {
		guard let states else {
			return .default
		}

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
					value.states?.contains(state) ?? false
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
			group.keys.count * group.items.map { physiology in
				Int(physiology.value.value(of: attack))
			}.reduce(into: 0) { cur, next in
				cur += next
			}
		}.reduce(into: 0) { cur, next in
			cur += next
		}

		let count = data.map { group in
			group.keys.count * group.items.count
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
