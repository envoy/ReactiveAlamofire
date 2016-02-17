//
//  SignalProducerTests.swift
//  ReactiveAlamofire
//
//  Created by Fang-Pen Lin on 2/16/16.
//  Copyright © 2016 Envoy. All rights reserved.
//

import XCTest

import Alamofire
import ReactiveCocoa

class SignalProducerTests: XCTestCase {

    func testSignalParseResponseWithStringSerializer() {
        let (signal, observer) = Signal<ResponseProducerResult, ResponseProducerResult>.pipe()
        var result: Alamofire.Response<String, NSError>?
        signal
            .parseResponse(Request.stringResponseSerializer())
            .observeNext { value in
                result = value
        }
        
        let data = "data".dataUsingEncoding(NSUTF8StringEncoding)!
        let response = NSHTTPURLResponse(
            URL: NSURL(string: "https://httpbin.org/get")!,
            statusCode: 200,
            HTTPVersion: "HTTP/1.1",
            headerFields: ["Content-Type": "image/jpeg; charset=utf-8"]
        )
        
        observer.sendNext(ResponseProducerResult(request: nil, response: response, data: data, error: nil))
        
        XCTAssertTrue(result!.result.isSuccess)
        XCTAssertEqual(result!.result.value, "data")
    }
    
    func testSignalParseResponseWithJSONSerializer() {
        let (signal, observer) = Signal<ResponseProducerResult, ResponseProducerResult>.pipe()
        var result: Alamofire.Response<AnyObject, NSError>?
        signal
            .parseResponse(Request.JSONResponseSerializer())
            .observeNext { value in
                result = value
        }
        
        let data = "{\"foo\": \"bar\"}".dataUsingEncoding(NSUTF8StringEncoding)!
        let response = NSHTTPURLResponse(
            URL: NSURL(string: "https://httpbin.org/get")!,
            statusCode: 200,
            HTTPVersion: "HTTP/1.1",
            headerFields: ["Content-Type": "application/json; charset=utf-8"]
        )
        
        observer.sendNext(ResponseProducerResult(request: nil, response: response, data: data, error: nil))
        
        XCTAssertTrue(result!.result.isSuccess)
        XCTAssertEqual(result!.result.value as! [String: String], ["foo": "bar"])
    }
    
    func testSignalParseResponseWithJSONSerializerAndBadJSONData() {
        let (signal, observer) = Signal<ResponseProducerResult, ResponseProducerResult>.pipe()
        let result = AnyProperty(initialValue: [], signal: signal.parseResponse(Request.JSONResponseSerializer()).materialize().collect())
        
        let data = "{".dataUsingEncoding(NSUTF8StringEncoding)!
        let response = NSHTTPURLResponse(
            URL: NSURL(string: "https://httpbin.org/get")!,
            statusCode: 200,
            HTTPVersion: "HTTP/1.1",
            headerFields: ["Content-Type": "application/json; charset=utf-8"]
        )
        
        observer.sendNext(ResponseProducerResult(request: nil, response: response, data: data, error: nil))
        observer.sendCompleted()
        
        XCTAssertEqual(result.value.count, 1)
        let event = result.value.first!
        XCTAssertTrue(event.isTerminating)
        let respWithError = event.error!
        XCTAssertTrue(respWithError.result.isFailure)
    }

}