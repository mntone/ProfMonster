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

	public static var copyright: String {
		info(key: "NSHumanReadableCopyright") as! String
	}

#if os(watchOS)
	@available(iOS, unavailable)
	@available(macOS, unavailable)
	public static var companionAppBundleIdentifier: String {
		info(key: "WKCompanionAppBundleIdentifier") as! String
	}
#endif

	public static var version: String {
		info(key: "MAVersion") as! String
	}

	public static var shortVersion: String {
		info(key: "MAShortVersion") as! String
	}

	public static var gitCurrent: String {
		info(key: "MAGitCurrent") as! String
	}

	public static var gitDate: Date {
		let gitDateString = info(key: "MAGitDate") as! String
		return dateFormatter.date(from: gitDateString)!
	}

	public static var gitHash: String {
		info(key: "MAGitHash") as! String
	}

	public static var gitHashOrigin: String {
		info(key: "MAGitHashOrigin") as! String
	}

	public static var gitOrigin: String {
		info(key: "MAGitOrigin") as! String
	}

	public static var dataSourceURL: URL {
		URL(string: info(key: "MADataSourceURL") as! String)!
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
