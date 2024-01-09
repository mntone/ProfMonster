import Foundation

private extension String {
	func replace亜種() -> String {
		if hasSuffix("亜種") {
			var that = self
			that.replaceSubrange(index(endIndex, offsetBy: -2)..<endIndex,
								 with: "アシュ")
			return that
		} else {
			return self
		}
	}

	func replace希少種() -> String {
		if hasSuffix("希少種") {
			var that = self
			that.replaceSubrange(index(endIndex, offsetBy: -3)..<endIndex,
								 with: "キショウシュ")
			return that
		} else {
			return self
		}
	}

	func replace傀異克服() -> String {
		if hasPrefix("傀異克服") {
			var that = self
			that.replaceSubrange(startIndex..<index(startIndex, offsetBy: 4),
								 with: "カイイコクフク")
			return that
		} else {
			return self
		}
	}
}

struct JapaneseTextProcessor: TextProcessor {
	private static let prolongedDict: [String] = [
		      "ア", "ア", "イ", "イ", "ウ", "ウ", "エ", "エ", "オ", "オ", "ア", "ア", "イ", "イ", "ウ",
		"ウ", "エ", "エ", "オ", "オ", "ア", "ア", "イ", "イ", "ウ", "ウ", "エ", "エ", "オ", "オ", "ア",
		"ア", "イ", "イ", "ウ", "ウ", "ウ", "エ", "エ", "オ", "オ", "ア", "イ", "ウ", "エ", "オ", "ア",
		"ア", "ア", "イ", "イ", "イ", "ウ", "ウ", "ウ", "エ", "エ", "エ", "オ", "オ", "オ", "ア", "イ",
		"ウ", "エ", "オ", "ア", "ア", "イ", "イ", "ウ", "ウ", "ア", "イ", "ウ", "エ", "オ", "ア", "ア",
		"イ", "エ", "オ", "ン", "ウ", "ア", "エ", "ア", "イ", "エ", "オ"
	]

	func normalize(forSearch searchText: String) -> String {
		searchText
			.lowercased()
			.applyingTransform(.hiraganaToKatakana, reverse: false)!
			.decomposedStringWithCompatibilityMapping  // NFKD
	}

	func normalize(fromReadable readableText: String) -> String {
		readableText
			.applyingTransform(.hiraganaToKatakana, reverse: false)!
			.decomposedStringWithCompatibilityMapping  // NFKD
	}

	func readable(from text: String) -> String {
		text.applyingTransform(.hiraganaToKatakana, reverse: false)!
			.replace亜種()
			.replace希少種()
			.replace傀異克服()
			.filter { char in
				!char.isWhitespace && char != "·" && char != "・"
			}
	}

	func latin(from readableText: String) -> String {
		readableText
			.applyingTransform(.latinToKatakana, reverse: true)!
			.filter { char in
				char != "'"
			}
	}

	func sortkey(from readableText: String) -> String {
		var reservedText = ""
		reservedText.reserveCapacity(readableText.lengthOfBytes(using: .utf8))

		let result = readableText.unicodeScalars.reduce(into: reservedText) { output, char in
			switch char.value {
			// Remove whitespace (ref. https://en.wikipedia.org/wiki/Whitespace_character)
			case 0x0020, // latin space
				 0x3000: // full-width space
				break

			// Remove a diacritic mark (ガ to カ)
			case 0x30AC...0x30C2 where char.value % 2 == 0,
				 0x30C5...0x30C9 where char.value % 2 == 1:
				output += String(Character(Unicode.Scalar(char.value - 1)!))
			case 0x30F4: // ヴ to ウ
				output += "ウ"
			//case 0x30F7...0x30FA: // ヷ to ワ
			//	output += String(Character(Unicode.Scalar(char.value - 7)!))

			// Remove a diacritic mark (バ/パ to ハ)
			case 0x30D0...0x30DD where char.value % 3 != 0:
				output += String(Character(Unicode.Scalar(char.value - char.value % 3)!))

			// Katakana to Large Katakana (ァ to ア)
			case 0x30A1...0x30A9 where char.value % 2 == 1,
				 0x30E3...0x30E7 where char.value % 2 == 1,
				 0x30EE:
				output += String(Character(Unicode.Scalar(char.value + 1)!))
			case 0x30F5: // ヵ
				output += "カ"
			case 0x30F6: // ヶ
				output += "ケ"
			//case 0x31F0: // ㇰ
			//	output += "ク"
			case 0x30C3: // ッ
				output += "ツ"

			// Remove a diacritic mark (が to カ)
			case 0x304C...0x3062 where char.value % 2 == 0,
				 0x3065...0x3069 where char.value % 2 == 1:
				output += String(Character(Unicode.Scalar(char.value + 0x5F)!))
			case 0x3094: // ゔ to ウ
				output += "ウ"

			// Remove a diacritic mark (バ/パ to ハ)
			case 0x3070...0x307D where char.value % 3 != 0:
				output += String(Character(Unicode.Scalar(char.value + 0x60 - char.value % 3)!))

			// Hiragana to Large Katakana (ぁ to ア)
			case 0x3041...0x3049 where char.value % 2 == 1,
				 0x3083...0x3087 where char.value % 2 == 1,
				 0x308E:
				output += String(Character(Unicode.Scalar(char.value + 0x61)!))
			case 0x3095: // ゕ
				output += "カ"
			case 0x3096: // ゖ
				output += "ケ"
			case 0x3063: // っ
				output += "ツ"

			// Hiragana to Katakana
			case 0x3041...0x3093:
				output += String(Character(Unicode.Scalar(char.value + 0x60)!))

			// Remove dot characters like "・" (ref. https://en.wikipedia.org/wiki/Interpunct)
			case 0x00B7, // latin dot
				 0x30FB: // katakana dot
				break

			// Convert prolonged sound mark.
			case 0x30FC where !output.isEmpty:
				let prevChar = output[output.index(before: output.endIndex)].unicodeScalars.first.unsafelyUnwrapped.value
				switch prevChar {
				case 0x30A1...0x30FA:
					output += Self.prolongedDict[Int(prevChar) - 0x30A1]
				default:
					output += String(char)
				}

			default:
				output += String(char)
			}
		}
		return result
	}
}
