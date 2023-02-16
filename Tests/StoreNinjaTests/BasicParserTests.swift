import Schwifty
import XCTest
@testable import StoreNinja

final class BasicParserTests: XCTestCase {
    var parser: BasicParser!
    
    override func setUp() {
        super.setUp()
        parser = BasicParser()
    }
    
    func testParseVersionFromHtml() throws {
        let fileName = "it.curzel.pets_2.36_2022.02.15"
        let url = try Bundle.module.urlForHtmlFile(named: fileName).unwrap()
        let data = try Data(contentsOf: url)
        let html = String(data: data, encoding: .utf8) ?? ""
        let result = parser.version(from: html)
        XCTAssertEqual("2.36", result)
    }
    
    func testReturnsNilWhenHtmlIsEmpty() throws {
        let result = parser.version(from: "")
        XCTAssertNil(result)
    }
    
    func testReturnsNilWhenVersionIsNotPresent() throws {
        let fileName = "it.curzel.pipper_first_release_2022.02.16"
        let url = try Bundle.module.urlForHtmlFile(named: fileName).unwrap()
        let data = try Data(contentsOf: url)
        let html = String(data: data, encoding: .utf8) ?? ""
        let result = parser.version(from: html)
        XCTAssertNil(result)
    }
}
