import PMKAlamofire
import OHHTTPStubs
import PromiseKit
import XCTest

class AlamofireTests: XCTestCase {
    func test() {
        let json: NSDictionary = ["key1": "value1", "key2": ["value2A", "value2B"]]

        OHHTTPStubs.stubRequests(passingTest: { $0.url!.host == "example.com" }) { _ in
            return OHHTTPStubsResponse(jsonObject: json, statusCode: 200, headers: nil)
        }

        let ex = expectation(description: "")

        let rq = Alamofire.request("http://example.com", method: .get).responseJSON().done { rsp in
            XCTAssertEqual(json, rsp.json as? NSDictionary)
            ex.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
    }

#if swift(>=3.2)
    private struct Fixture: Decodable {
        let key1: String
        let key2: [String]
    }
    
    func testDecodable1() {
        
        func getFixture() -> Promise<Fixture> {
            return Alamofire.request("http://example.com", method: .get).responseDecodable(queue: nil)
        }
        
        let json: NSDictionary = ["key1": "value1", "key2": ["value2A", "value2B"]]
        
        OHHTTPStubs.stubRequests(passingTest: { $0.url!.host == "example.com" }) { _ in
            return OHHTTPStubsResponse(jsonObject: json, statusCode: 200, headers: nil)
        }
        
        let ex = expectation(description: "")
        
        getFixture().done { fixture in
            XCTAssert(fixture.key1 == "value1", "Value1 found")
            ex.fulfill()
        }
        waitForExpectations(timeout: 1)
        
    }
    
    func testDecodable2() {
        let json: NSDictionary = ["key1": "value1", "key2": ["value2A", "value2B"]]
        
        OHHTTPStubs.stubRequests(passingTest: { $0.url!.host == "example.com" }) { _ in
            return OHHTTPStubsResponse(jsonObject: json, statusCode: 200, headers: nil)
        }
        
        let ex = expectation(description: "")
        
        firstly {
            Alamofire.request("http://example.com", method: .get).responseDecodable(Fixture.self)
        }.done { fixture in
            XCTAssert(fixture.key1 == "value1", "Value1 found")
            ex.fulfill()
        }
        waitForExpectations(timeout: 1)
        
    }
#endif
}

//////////////////////////////////////////////////////////// Cancellation

extension AlamofireTests {
    func testCancel() {
        let json: NSDictionary = ["key1": "value1", "key2": ["value2A", "value2B"]]
        
        OHHTTPStubs.stubRequests(passingTest: { $0.url!.host == "example.com" }) { _ in
            return OHHTTPStubsResponse(jsonObject: json, statusCode: 200, headers: nil)
        }
        
        let ex = expectation(description: "")
        
        firstly {
            cancellable(Alamofire.request("http://example.com", method: .get).responseJSON())
        }.done { _ in
            XCTFail("failed to cancel request")
        }.catch(policy: .allErrors) { error in
            error.isCancelled ? ex.fulfill() : XCTFail("Error: \(error)")
        }.cancel()
        
        waitForExpectations(timeout: 1)
    }

#if swift(>=3.2)
    func testCancelDecodable1() {
        
        func getFixture() -> CancellablePromise<Fixture> {
            return cancellable(Alamofire.request("http://example.com", method: .get).responseDecodable(queue: nil))
        }
        
        let json: NSDictionary = ["key1": "value1", "key2": ["value2A", "value2B"]]
        
        OHHTTPStubs.stubRequests(passingTest: { $0.url!.host == "example.com" }) { _ in
            return OHHTTPStubsResponse(jsonObject: json, statusCode: 200, headers: nil)
        }
        
        let ex = expectation(description: "")
        
        getFixture().done { fixture in
            XCTAssert(fixture.key1 == "value1", "Value1 found")
            XCTFail("failed to cancel request")
        }.catch(policy: .allErrors) { error in
            error.isCancelled ? ex.fulfill() : XCTFail("Error: \(error)")
        }.cancel()
        
        waitForExpectations(timeout: 1)
    }
    
    func testCancelDecodable2() {
        let json: NSDictionary = ["key1": "value1", "key2": ["value2A", "value2B"]]
        
        OHHTTPStubs.stubRequests(passingTest: { $0.url!.host == "example.com" }) { _ in
            return OHHTTPStubsResponse(jsonObject: json, statusCode: 200, headers: nil)
        }
        
        let ex = expectation(description: "")
        
        firstly {
            Alamofire.request("http://example.com", method: .get).cancellableResponseDecodable(Fixture.self)
        }.done { fixture in
            XCTAssert(fixture.key1 == "value1", "Value1 found")
            XCTFail("failed to cancel request")
        }.catch(policy: .allErrors) { error in
            error.isCancelled ? ex.fulfill() : XCTFail("Error: \(error)")
        }.cancel()
        
        waitForExpectations(timeout: 1)
        
    }
    #endif
}
