//
//  SonorTests.swift
//  SonorTests
//
//  Created by Yuwei Ba on 7/21/19.
//  Copyright © 2019 Watfaq. All rights reserved.
//

import XCTest

class SonorTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testMergingImages() {
        let bundle = Bundle(for: type(of: self))
        let images = bundle.paths(forResourcesOfType: "jpeg", inDirectory: nil).map{ UIImage(contentsOfFile: $0)}.compactMap{$0}
        XCTAssertTrue(images.count == 3)
        
        _ = OpenCVWrapper.mergeLongExposure(images)
    }
}
