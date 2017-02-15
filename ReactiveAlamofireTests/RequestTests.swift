//
//  RequestTests.swift
//  ReactiveAlamofire
//
//  Created by Fang-Pen Lin on 2/16/16.
//  Copyright © 2016 Envoy. All rights reserved.
//

import XCTest

import Alamofire
import ReactiveSwift

class RequestTests: XCTestCase {
    func testResponseProducer() {
        let exp = expectation(description: "get response")
        Alamofire.request("http://httpbin.org/get")
            .responseProducer()
            .startWithResult { result in
                XCTAssertNotNil(result.value)
                XCTAssertNotNil(result.value!.data)
                XCTAssertNotNil(result.value!.request)
                XCTAssertNotNil(result.value!.response)
                XCTAssertNil(result.error)
                exp.fulfill()
        }
        waitForExpectations(timeout: 3, handler: nil)
    }

}
