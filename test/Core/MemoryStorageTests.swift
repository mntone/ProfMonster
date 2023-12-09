import XCTest
@testable import MonsterAnalyzerCore

class MemoryStorageTests: XCTestCase {
	struct TestObject: Codable {
		let integer: Int
		let string: String
	}
	
	func testStoreAndLoad() throws {
		let storage = MemoryStorage()
		let randomInteger = Int.random(in: Int.min...Int.max)
		let someObject = TestObject(integer: randomInteger, string: "string")
		let ret = storage.store(someObject, for: "someObject")
		XCTAssertTrue(ret) // Always returns true
		
		let loadObject = storage.load(of: TestObject.self, for: "someObject")
		XCTAssertNotNil(loadObject)
		XCTAssertEqual(loadObject!.integer, randomInteger)
		XCTAssertEqual(loadObject!.string, "string")
	}

    func testLoadNothing() throws {
		let storage = MemoryStorage()
		let nilObject = storage.load(of: TestObject.self, for: "nilObject")
		XCTAssertNil(nilObject)
    }
}
