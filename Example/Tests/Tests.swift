import XCTest
import RestStop
import RxSwift
import RxBlocking

class Tests: XCTestCase {
    static var store: Store?
    
    override class func setUp() {
        super.setUp()
        
        let client = DefaultJsonClient();
        let adapter = INaturalistRestAdapter(baseUrlString: "https://api.inaturalist.org/v1/", httpClient: client);
        self.store = Store(adapter: adapter);
    }
    
    override class func tearDown() {
        super.tearDown()
        self.store = nil
    }
    
    func testGet() {
        let result = try! Tests.store!.resource(name: "observations").getList().toBlocking().first()!
        XCTAssert(result.total > 0)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
}

class INaturalistRestAdapter : DefaultRestAdapter {
    
}

