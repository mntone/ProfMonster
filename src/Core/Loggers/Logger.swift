import Foundation

public protocol Logger {
	func debug(_ message: String, file: StaticString, function: StaticString, line: UInt)
	func info(_ message: String, file: StaticString, function: StaticString, line: UInt)
	func notice(_ message: String, file: StaticString, function: StaticString, line: UInt)
	func error(_ message: String, file: StaticString, function: StaticString, line: UInt)
	func fault(_ message: String, file: StaticString, function: StaticString, line: UInt) -> Never
}

public extension Logger {
	func debug(_ message: String,
			   file: StaticString = #file,
			   function: StaticString = #function,
			   line: UInt = #line) {
		debug(message, file: file, function: function, line: line)
	}

	func info(_ message: String,
			  file: StaticString = #file,
			  function: StaticString = #function,
			  line: UInt = #line) {
		info(message, file: file, function: function, line: line)
	}

	func notice(_ message: String,
				file: StaticString = #file,
				function: StaticString = #function,
				line: UInt = #line) {
		notice(message, file: file, function: function, line: line)
	}

	func error(_ message: String,
			   file: StaticString = #file,
			   function: StaticString = #function,
			   line: UInt = #line) {
		error(message, file: file, function: function, line: line)
	}

	func fault(_ message: String,
			   file: StaticString = #file,
			   function: StaticString = #function,
			   line: UInt = #line) -> Never {
		fault(message, file: file, function: function, line: line)
	}

	func notImplemented(file: StaticString = #file,
						function: StaticString = #function,
						line: UInt = #line) -> Never {
		fault("Not Implemented", file: file, function: function, line: line)
	}
}
