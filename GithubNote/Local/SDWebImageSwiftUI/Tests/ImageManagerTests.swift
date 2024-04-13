import XCTest
import SwiftUI
import ViewInspector
@testable import SDWebImageSwiftUI

class ImageManagerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testImageManager() throws {
        let expectation = self.expectation(description: "ImageManager usage with Combine")
        let imageUrl = URL(string: "https://placehold.co/500x500.jpg")
        let imageManager = ImageManager()
        imageManager.setOnSuccess { image, cacheType, data in
            XCTAssertNotNil(image)
            expectation.fulfill()
        }
        imageManager.setOnFailure { error in
            XCTFail()
        }
        imageManager.setOnProgress { receivedSize, expectedSize in
            
        }
        imageManager.load(url: imageUrl)
        XCTAssertNotNil(imageManager.currentOperation)
        let sub = imageManager.objectWillChange
            .subscribe(on: RunLoop.main)
            .receive(on: RunLoop.main)
            .sink { value in
                print(value)
        }
        sub.cancel()
        self.waitForExpectations(timeout: 10, handler: nil)
    }
}
