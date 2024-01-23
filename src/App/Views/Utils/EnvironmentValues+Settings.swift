import class MonsterAnalyzerCore.Settings
import SwiftUI

private struct _SettingsEnvironmentKey: EnvironmentKey {
	static var defaultValue: MonsterAnalyzerCore.Settings? = nil
}

extension EnvironmentValues {
	var settings: MonsterAnalyzerCore.Settings? {
		get { self[_SettingsEnvironmentKey.self] }
		set { self[_SettingsEnvironmentKey.self] = newValue }
	}
}
