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
        let exp = expectation(description: "get response")
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
        waitForExpectations(timeout: 3, handler: nil)
    }

    func testRequestProducerToResponseProducerWithJSONParsing() {
        let exp = expectation(description: "get response")
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
        waitForExpectations(timeout: 3, handler: nil)
    }

    func testRequestProducerToResponseProducerWithMultipleReq() {
        let exp0 = expectation(description: "get 1st response")
        let exp1 = expectation(description: "get 2nd response")
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
        waitForExpectations(timeout: 3, handler: nil)
        
        XCTAssertEqual(results, [["foo": "bar"], ["egg": "spam"]])
    }

    func testRequestProducerToResponseProducerWithMerging() {
        let num = 10
        var exps = (0..<num).map { expectation(description: "get \($0)st response") }
        let requests = (0..<num).map { Alamofire.request(.GET, "http://httpbin.org/get?req=\($0)") }
        var results: Set<Int> = []
        SignalProducer(values: requests)
            .responseProducer(.Merge)
            .parseResponse(Request.JSONResponseSerializer())
            .startWithNext { result in
                XCTAssertNotNil(result.data)
                XCTAssertNotNil(result.request)
                XCTAssertNotNil(result.response)
                XCTAssertTrue(result.result.isSuccess)
                let dict = result.result.value! as! [String: AnyObject]
                let exp = exps.removeLast()
                exp.fulfill()
                let numStr = ((dict["args"]! as? [String: String])?["req"])! as String
                results.insert(Int(numStr)!)
        }
        waitForExpectations(timeout: 10, handler: nil)
        
        let expectedNumbers: Set<Int> = Set<Int>(0..<num)
        XCTAssertEqual(results, expectedNumbers)
    }
}
