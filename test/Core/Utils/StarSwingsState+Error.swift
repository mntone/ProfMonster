import MonsterAnalyzerCore

extension StarSwingsState {
	var error: StarSwingsError? {
		switch self {
		case let .failure(_, error):
			return error
		default:
			return nil
		}
	}
}
