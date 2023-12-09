import Foundation

public enum AppUtil {
	public static var isTest: Bool {
		NSClassFromString("XCTest") != nil
	}

	public static var isPreview: Bool {
		ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil
	}
}
