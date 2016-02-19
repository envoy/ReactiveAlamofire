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
import Result

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

    func testRequestProducerToResponseProducerWithJSONParsing() {
        let exp = expectationWithDescription("get response")
        SignalProducer<Request, NoError> { observer, _ in
            let req = Alamofire.request(.GET, "http://httpbin.org/get?foo=bar")
            observer.sendNext(req)
        }
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

    func testRequestProducerToResponseProducerWithMultipleReq() {
        let exp0 = expectationWithDescription("get 1st response")
        let exp1 = expectationWithDescription("get 2nd response")
        var results: [[String: String]] = []
        SignalProducer(values: [
            Alamofire.request(.GET, "http://httpbin.org/get?foo=bar"),
            Alamofire.request(.GET, "http://httpbin.org/get?egg=spam")
        ])
            .responseProducer()
            .parseResponse(Request.JSONResponseSerializer())
            .startWithNext { result in
                XCTAssertNotNil(result.data)
                XCTAssertNotNil(result.request)
                XCTAssertNotNil(result.response)
                XCTAssertTrue(result.result.isSuccess)
                let dict = result.result.value! as! [String: AnyObject]
                if results.count == 0 {
                    exp0.fulfill()
                } else {
                    exp1.fulfill()
                }
                results.append(dict["args"] as! [String: String])
        }
        waitForExpectationsWithTimeout(3, handler: nil)
        
        XCTAssertEqual(results, [["foo": "bar"], ["egg": "spam"]])
    }
}
