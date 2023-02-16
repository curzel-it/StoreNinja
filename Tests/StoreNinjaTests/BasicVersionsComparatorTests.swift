import Schwifty
import XCTest
@testable import StoreNinja

final class BasicVersionsComparatorTests: XCTestCase {
    var comparator: BasicVersionsComparator!
    
    override func setUp() {
        super.setUp()
        comparator = BasicVersionsComparator()
    }
    
    func testConvertsVersionsToNumbersProperly() {
        XCTAssertEqual(comparator.numbers(from: ""), [0])
        XCTAssertEqual(comparator.numbers(from: "a"), [0])
        XCTAssertEqual(comparator.numbers(from: "1"), [1])
        XCTAssertEqual(comparator.numbers(from: "1.0"), [1, 0])
        XCTAssertEqual(comparator.numbers(from: "1.a"), [1, 0])
        XCTAssertEqual(comparator.numbers(from: "1.2"), [1, 2])
        XCTAssertEqual(comparator.numbers(from: "1.2.3"), [1, 2, 3])
        XCTAssertEqual(comparator.numbers(from: "1.a.3"), [1, 0, 3])
        XCTAssertEqual(comparator.numbers(from: "1.2.b"), [1, 2, 0])
        XCTAssertEqual(comparator.numbers(from: "1.23.45"), [1, 23, 45])
        XCTAssertEqual(comparator.numbers(from: "0.0.0"), [0, 0, 0])
    }
    
    func testNumbersComparisonOfEqualCount1() {
        XCTAssertEqual(comparator.compare([0], [0]), .equivalent)
        XCTAssertEqual(comparator.compare([1], [0]), .newer)
        XCTAssertEqual(comparator.compare([0], [1]), .older)
        XCTAssertEqual(comparator.compare([1], [1]), .equivalent)
    }
    
    func testNumbersComparisonOfEqualCount2() {
        XCTAssertEqual(comparator.compare([0, 0], [0, 0]), .equivalent)
        XCTAssertEqual(comparator.compare([0, 1], [0, 1]), .equivalent)
        XCTAssertEqual(comparator.compare([1, 0], [0, 1]), .newer)
        XCTAssertEqual(comparator.compare([0, 1], [1, 0]), .older)
        XCTAssertEqual(comparator.compare([1, 0], [1, 0]), .equivalent)
        XCTAssertEqual(comparator.compare([1, 2], [1, 1]), .newer)
        XCTAssertEqual(comparator.compare([1, 2], [1, 2]), .equivalent)
        XCTAssertEqual(comparator.compare([1, 2], [1, 3]), .older)
    }
    
    func testComparisonOfNonEqualCount() {
        XCTAssertEqual(comparator.compare("0", "0.0"), .equivalent)
        XCTAssertEqual(comparator.compare("0", "0.1"), .older)
        XCTAssertEqual(comparator.compare("1", "0.1"), .newer)
        XCTAssertEqual(comparator.compare("0.1", "0.1.1"), .older)
        XCTAssertEqual(comparator.compare("0.1.1", "0.1"), .newer)
        XCTAssertEqual(comparator.compare("0.1.1", "0.1.1"), .equivalent)
        XCTAssertEqual(comparator.compare("0.1.1", "0.1.1.0.0"), .equivalent)
        XCTAssertEqual(comparator.compare("0.1.1.0.0", "0.1.1"), .equivalent)
    }
}
