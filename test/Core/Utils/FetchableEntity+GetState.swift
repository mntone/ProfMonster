import Combine
@testable import MonsterAnalyzerCore

extension FetchableEntity {
	@discardableResult
	func getState(in set: inout Set<AnyCancellable>) async -> StarSwingsState {
		var result = state
		if case .loading = state {
			result = await $state.dropFirst().get(in: &set)
		}
		return result
	}
}
