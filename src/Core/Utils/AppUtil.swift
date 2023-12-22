import Foundation

public enum AppUtil {
	public static var isTest: Bool {
		NSClassFromString("XCTest") != nil
	}

	public static var isPreview: Bool {
		ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil
	}

	public static var bundleVersion: String {
		info(key: "CFBundleVersion") as! String
	}

	public static var bundleShortVersion: String {
		info(key: "CFBundleShortVersionString") as! String
	}

	public static var gitDate: Date {
		let gitDateString = info(key: "MAGitDateString") as! String
		return dateFormatter.date(from: gitDateString)!
	}

	public static var gitHash: String {
		info(key: "MAGitHashString") as! String
	}

	private static func info(key: String) -> Any? {
		Bundle.main.object(forInfoDictionaryKey: key)
	}

	private static let dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZZ"
		return formatter
	}()
}
