import Foundation

enum PhysiologyMapper {
	private static let removingState: Set<String> = ["default", "broken"]

	private static func localizedStates(_ keys: [String]) -> [String] {
		// TODO: Localize
		keys.map { key in
			key.replacingOccurrences(of: "_", with: " ").capitalized
		}
	}

	private static func getStateInfo(_ states: [String]) -> PhysiologyStateInfo {
		if states.contains("broken") {
			return .broken
		} else if states.contains("default") {
			return .default
		} else {
			return .other
		}
	}

	private static func map(_ src: MHMonsterPhysiologyValue, states: [String]? = nil) -> Physiology {
		let baseStates = states ?? src.states
		return Physiology(stateInfo: getStateInfo(baseStates),
						  states: localizedStates(baseStates),
						  value: PhysiologyValue(slash: src.slash,
												 strike: src.strike,
												 shell: src.shell,
												 fire: src.fire,
												 water: src.water,
												 thunder: src.thunder,
												 ice: src.ice,
												 dragon: src.dragon),
						  stun: src.stun)
	}

	private static func getAverage(_ data: [PhysiologyGroup], of attack: Attack) -> Float {

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
		return Float(sum) / Float(count)
	}

	private static func getAverages(_ data: [PhysiologyGroup]) -> PhysiologyValue<Float> {
		PhysiologyValue(slash: Self.getAverage(data, of: .slash),
						strike: Self.getAverage(data, of: .strike),
						shell: Self.getAverage(data, of: .shell),
						fire: Self.getAverage(data, of: .fire),
						water: Self.getAverage(data, of: .water),
						thunder: Self.getAverage(data, of: .thunder),
						ice: Self.getAverage(data, of: .ice),
						dragon: Self.getAverage(data, of: .dragon))
	}

	static func map(json src: MHMonster) -> Physiologies {
		let allAbnormalStates = Set(src.physiologies.flatMap { physiologies in
			Array(Set(physiologies.values.flatMap(\.states)))
		}).subtracting(Self.removingState).filter { state in
			src.physiologies.allSatisfy { physiologies in
				physiologies.values.contains { value in
					value.states.contains(state)
				}
			}
		}

		let defaultSectionData = src.physiologies.map { physiology in
			let items = physiology.values.compactMap { physiologyValue -> Physiology? in
				guard !physiologyValue.states.contains(where: { s in allAbnormalStates.contains(s) }) else {
					return nil
				}
				return map(physiologyValue)
			}
			return PhysiologyGroup(parts: physiology.parts,
								   items: items)
		}
		let defaultSection = PhysiologySection(state: "default",
											   groups: defaultSectionData,
											   average: getAverages(defaultSectionData))

		var abnormalSections = allAbnormalStates.map { targetState in
			let sectionData = src.physiologies.map { physiology in
				let items = physiology.values.compactMap { physiologyValue -> Physiology? in
					guard physiologyValue.states.contains(targetState) else {
						return nil
					}
					var filteredState = physiologyValue.states.filter { state in
						state != targetState
					}
					if filteredState.isEmpty {
						filteredState.append("default")
					}
					return map(physiologyValue, states: filteredState)
				}
				return PhysiologyGroup(parts: physiology.parts,
									   items: items)
			}
			return PhysiologySection(state: targetState,
									 groups: sectionData,
									 average: getAverages(sectionData))
		}
		abnormalSections.insert(defaultSection, at: 0)

		return Physiologies(id: src.id, sections: abnormalSections)
	}
}
