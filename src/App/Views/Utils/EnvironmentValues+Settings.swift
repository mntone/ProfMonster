import class MonsterAnalyzerCore.Settings
import SwiftUI

struct SettingsEnvironmentKey: EnvironmentKey {
	static var defaultValue: MonsterAnalyzerCore.Settings? = nil
}

extension EnvironmentValues {
	var settings: MonsterAnalyzerCore.Settings? {
		get { self[SettingsEnvironmentKey.self] }
		set { self[SettingsEnvironmentKey.self] = newValue }
	}
}
