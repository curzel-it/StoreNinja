import BareBones
import XCTest
@testable import StoreNinja

final class StoreNinjaTests: XCTestCase {
    var checker: StoreVersionChecker!
    
    override func setUp() async throws {
        try await super.setUp()
        checker = StoreNinja.checker(appId: "1575542220")
        HttpClient.removeAllInterceptors()
    }
    
    func testCanGetVersionOfAppFromKnownFormat() async throws {
        let dataUrl = try Bundle.module.urlForHtmlFile(named: "it.curzel.pets_2.36_2022.02.15").unwrap()
        let testData = try Data(contentsOf: dataUrl)
        HttpClient.add(interceptor: Interceptor(when: .always, return: testData))
        
        let response = await checker.storeVersion()
        switch response {
        case .success(let version): XCTAssertEqual(version, "2.36")
        case .failure: XCTAssert(false)
        }
    }
    
    func testCanGetVersionOfAppFromCurrentFormat() async throws {
        let response = await checker.storeVersion()
        switch response {
        case .success(let version):
            XCTAssertEqual(BasicVersionsComparator().compare(version, "2.35"), .newer)
        case .failure: XCTAssert(false)
        }
    }
    
    func testKnowsIfAnUpdateIsAvailable() async throws {
        let update = await checker.availableUpdate(from: "1.0.0")
        if case .updateAvailable = update {
            XCTAssert(true)
        } else {
            XCTAssert(false)
        }
    }
    
    func testKnowsIfAnUpdateIsNotAvailable() async throws {
        let update = await checker.availableUpdate(from: "100.0.0")
        XCTAssertEqual(.noUpdatesAvailable, update)
    }
    
    func testKnowsIfAVersionHasBeenReleased() async throws {
        let update = await checker.isReleased(version: "1.0.0")
        if case .yes(let isLatest) = update {
            XCTAssert(!isLatest)
        } else {
            XCTAssert(false)
        }
    }
    
    func testKnowsIfAVersionHasNotBeenReleased() async throws {
        let update = await checker.isReleased(version: "100.0.0")
        if case .no = update {
            XCTAssert(true)
        } else {
            XCTAssert(false)
        }
    }
}
