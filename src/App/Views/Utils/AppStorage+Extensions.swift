import class MonsterAnalyzerCore.Settings
import SwiftUI

extension AppStorage {
	init(settings settingsKeyPath: PartialKeyPath<MonsterAnalyzerCore.Settings>) where Value == Bool {
		self.init(wrappedValue: settingsKeyPath.getDefaultValue(),
				  settingsKeyPath.userDefaultKeyName)
	}

	init(settings settingsKeyPath: PartialKeyPath<MonsterAnalyzerCore.Settings>) where Value == String {
		self.init(wrappedValue: settingsKeyPath.getDefaultValue(),
				  settingsKeyPath.userDefaultKeyName)
	}

	init(settings settingsKeyPath: PartialKeyPath<MonsterAnalyzerCore.Settings>) where Value: RawRepresentable, Value.RawValue == String {
		self.init(wrappedValue: Value(rawValue: settingsKeyPath.getDefaultValue())!,
				  settingsKeyPath.userDefaultKeyName)
	}
}
