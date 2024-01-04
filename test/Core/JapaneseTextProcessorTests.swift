import XCTest
@testable import MonsterAnalyzerCore

class JapaneseTextProcessorTests: XCTestCase {
	private let p: TextProcessor = JapaneseTextProcessor()

	func testRemoveWhitespacesOrDots() {
		let tables = [
			" ", // latin space
			"　", // full-width space
			"·", // latin dot
			"・", // katakana dot
		]
		for key in tables {
			let result = p.sortkey(from: key)
			XCTAssertTrue(result.isEmpty)
		}
	}

	func testHiraganaToKatakana() {
		let result = p.sortkey(from: "あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわゐゑをん")
		XCTAssertEqual(result, "アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヰヱヲン")
	}

	func testSmallHiraganaToLargeKatakana() {
		let result = p.sortkey(from: "ぁぃぅぇぉゕゖっゃゅょゎ")
		XCTAssertEqual(result, "アイウエオカケツヤユヨワ")
	}

	func testSmallKatakanaToLarge() {
		let result = p.sortkey(from: "ァィゥェォヵヶッャュョヮ")
		XCTAssertEqual(result, "アイウエオカケツヤユヨワ")
	}

	func testDiacriticHiraganaToNonDiacriticKatakana() {
		let result = p.sortkey(from: "ゔがぎぐげござじずぜぞだぢづでどばびぶべぼぱぴぷぺぽ")
		XCTAssertEqual(result, "ウカキクケコサシスセソタチツテトハヒフヘホハヒフヘホ")
	}

	func testDiacriticKatakanaToNonDiacritic() {
		let result = p.sortkey(from: "ヴガギグゲゴザジズゼゾダヂヅデドバビブベボパピプペポ")
		XCTAssertEqual(result, "ウカキクケコサシスセソタチツテトハヒフヘホハヒフヘホ")
	}
}
