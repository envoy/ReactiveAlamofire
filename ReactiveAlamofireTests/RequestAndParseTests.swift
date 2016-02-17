//
//  RequestAndParseTests.swift
//  ReactiveAlamofire
//
//  Created by Fang-Pen Lin on 2/16/16.
//  Copyright © 2016 Envoy. All rights reserved.
//

import XCTest

import Alamofire
import ReactiveCocoa

class RequestAndParseTests: XCTestCase {
    func testResponseProducerWithJSONParsing() {
        let exp = expectationWithDescription("get response")
        Alamofire.request(.GET, "http://httpbin.org/get?foo=bar")
            .responseProducer()
            .parseResponse(Request.JSONResponseSerializer())
            .startWithNext { result in
                XCTAssertNotNil(result.data)
                XCTAssertNotNil(result.request)
                XCTAssertNotNil(result.response)
                XCTAssertTrue(result.result.isSuccess)
                let dict = result.result.value! as! [String: AnyObject]
                XCTAssertEqual(dict["args"] as! [String: String], ["foo": "bar"])
                exp.fulfill()
        }
        waitForExpectationsWithTimeout(3, handler: nil)
    }
}
