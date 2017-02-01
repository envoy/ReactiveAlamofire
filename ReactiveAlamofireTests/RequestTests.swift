//
//  RequestTests.swift
//  ReactiveAlamofire
//
//  Created by Fang-Pen Lin on 2/16/16.
//  Copyright © 2016 Envoy. All rights reserved.
//

import XCTest

import Alamofire
import ReactiveCocoa

class RequestTests: XCTestCase {
    func testResponseProducer() {
        let exp = expectation(description: "get response")
        Alamofire.request(.GET, "http://httpbin.org/get")
            .responseProducer()
            .startWithNext { result in
                XCTAssertNotNil(result.data)
                XCTAssertNotNil(result.request)
                XCTAssertNotNil(result.response)
                XCTAssertNil(result.error)
                exp.fulfill()
        }
        waitForExpectations(timeout: 3, handler: nil)
    }

}
