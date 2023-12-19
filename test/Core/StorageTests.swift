import XCTest
@testable import MonsterAnalyzerCore

class StorageTests: XCTestCase {
	struct TestObject: Codable {
		let integer: Int
		let string: String
	}

	private func testStoreAndLoad(_ storage: Storage) throws {
		let randomInteger = Int.random(in: Int.min...Int.max)
		let someObject = TestObject(integer: randomInteger, string: "string")
		let ret = storage.store(someObject, for: "someObject")
		XCTAssertTrue(ret) // Always returns true if successful

		let loadObject = storage.load(of: TestObject.self, for: "someObject")
		XCTAssertNotNil(loadObject)
		XCTAssertEqual(loadObject!.integer, randomInteger)
		XCTAssertEqual(loadObject!.string, "string")
	}

	func testDiskStoreAndLoad() throws {
		let storage = MemoryStorage()
		try testStoreAndLoad(storage)
	}

    func testDiskLoadNothing() throws {
		let storage = DiskStorage()
		let nilObject = storage.load(of: TestObject.self, for: "nilObject")
		XCTAssertNil(nilObject)
    }

	func testMemoryStoreAndLoad() throws {
		let storage = MemoryStorage()
		try testStoreAndLoad(storage)
	}

	func testMemoryLoadNothing() throws {
		let storage = MemoryStorage()
		let nilObject = storage.load(of: TestObject.self, for: "nilObject")
		XCTAssertNil(nilObject)
	}
}
