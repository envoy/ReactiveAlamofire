//
//  RequestAndParseTests.swift
//  ReactiveAlamofire
//
//  Created by Fang-Pen Lin on 2/16/16.
//  Copyright © 2016 Envoy. All rights reserved.
//

import XCTest

import Alamofire
import ReactiveSwift
import Result

class RequestAndParseTests: XCTestCase {
    func testResponseProducerWithJSONParsing() {
        let exp = expectation(description: "get response")
        Alamofire.request("http://httpbin.org/get?foo=bar")
            .responseProducer()
            .parseResponse(DataRequest.jsonResponseSerializer())
            .startWithResult { result in
                let response = result.value!
                XCTAssertNotNil(response.data)
                XCTAssertNotNil(response.request)
                XCTAssertNotNil(response.response)
                XCTAssertTrue(response.result.isSuccess)
                let dict = response.result.value! as! [String: AnyObject]
                XCTAssertEqual(dict["args"] as! [String: String], ["foo": "bar"])
                exp.fulfill()
        }
        waitForExpectations(timeout: 3, handler: nil)
    }

    func testRequestProducerToResponseProducerWithJSONParsing() {
        let exp = expectation(description: "get response")
        SignalProducer<DataRequest, NoError> { observer, _ in
            let req = Alamofire.request("http://httpbin.org/get?foo=bar")
            observer.send(value: req)
        }
            .responseProducer()
            .parseResponse(DataRequest.jsonResponseSerializer())
            .startWithResult { result in
                let response = result.value!
                XCTAssertNotNil(response.data)
                XCTAssertNotNil(response.request)
                XCTAssertNotNil(response.response)
                XCTAssertTrue(response.result.isSuccess)
                let dict = response.result.value! as! [String: AnyObject]
                XCTAssertEqual(dict["args"] as! [String: String], ["foo": "bar"])
                exp.fulfill()
        }
        waitForExpectations(timeout: 3, handler: nil)
    }

    func testRequestProducerToResponseProducerWithMultipleReq() {
        let exp0 = expectation(description: "get 1st response")
        let exp1 = expectation(description: "get 2nd response")
        var results: [[String: Any]] = []
        SignalProducer([
            Alamofire.request("http://httpbin.org/get?foo=bar"),
            Alamofire.request("http://httpbin.org/get?egg=spam")
        ])
            .responseProducer()
            .parseResponse(DataRequest.jsonResponseSerializer())
            .startWithResult { result in
                let response = result.value!
                XCTAssertNotNil(response.data)
                XCTAssertNotNil(response.request)
                XCTAssertNotNil(response.response)
                XCTAssertTrue(response.result.isSuccess)
                let dict = response.result.value! as! [String: Any]

                if results.count == 0 {
                    exp0.fulfill()
                } else {
                    exp1.fulfill()
                }
                results.append(dict["args"] as! [String: Any])
        }
        waitForExpectations(timeout: 3, handler: nil)

//        let expected: [[String: NSObject] = [["foo": "bar"], ["egg": "spam"]]
//        XCTAssertEqual(results[0]["foo"], "bar")
    }

    func testRequestProducerToResponseProducerWithMerging() {
        let num = 10
        var exps = (0..<num).map { expectation(description: "get \($0)st response") }
        let requests = (0..<num).map { Alamofire.request("http://httpbin.org/get?req=\($0)") }
        var results: Set<Int> = []
        SignalProducer(requests)
            .responseProducer(.merge)
            .parseResponse(DataRequest.jsonResponseSerializer())
            .startWithResult { result in
                let response = result.value!
                XCTAssertNotNil(response.data)
                XCTAssertNotNil(response.request)
                XCTAssertNotNil(response.response)
                XCTAssertTrue(response.result.isSuccess)
                let dict = response.result.value! as! [String: AnyObject]
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
