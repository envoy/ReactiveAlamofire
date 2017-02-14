//
//  SignalProducerTests.swift
//  ReactiveAlamofire
//
//  Created by Fang-Pen Lin on 2/16/16.
//  Copyright © 2016 Envoy. All rights reserved.
//

import XCTest

import Alamofire
import ReactiveSwift

class SignalProducerTests: XCTestCase {

    func testSignalParseResponseWithStringSerializer() {
        let (signal, observer) = Signal<ResponseProducerResult, ResponseProducerResult>.pipe()
        var result: DataResponse<String>?
        signal
            .parseResponse(DataRequest.stringResponseSerializer())
            .observeResult { value in
                result = value.value
        }
        
        let data = "data".data(using: String.Encoding.utf8)!
        let response = HTTPURLResponse(
            url: URL(string: "https://httpbin.org/get")!,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Type": "image/jpeg; charset=utf-8"]
        )
        
        observer.send(value: ResponseProducerResult(request: nil, response: response, data: data, error: nil))

        XCTAssertTrue(result!.result.isSuccess)
        XCTAssertEqual(result!.result.value, "data")
    }
    
    func testSignalParseResponseWithJSONSerializer() {
        let (signal, observer) = Signal<ResponseProducerResult, ResponseProducerResult>.pipe()
        var result: DataResponse<Any>?
        signal
            .parseResponse(DataRequest.jsonResponseSerializer())
            .observeResult { value in
                result = value.value
        }
        
        let data = "{\"foo\": \"bar\"}".data(using: String.Encoding.utf8)!
        let response = HTTPURLResponse(
            url: URL(string: "https://httpbin.org/get")!,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Type": "application/json; charset=utf-8"]
        )
        
        observer.send(value: ResponseProducerResult(request: nil, response: response, data: data, error: nil))
        
        XCTAssertTrue(result!.result.isSuccess)
        XCTAssertEqual(result!.result.value as! [String: String], ["foo": "bar"])
    }
    
    func testSignalParseResponseWithJSONSerializerAndBadJSONData() {
        let (signal, observer) = Signal<ResponseProducerResult, ResponseProducerResult>.pipe()
        let result = Property(initial: [], then: signal.parseResponse(DataRequest.jsonResponseSerializer()).materialize().collect())
        
        let data = "{".data(using: String.Encoding.utf8)!
        let response = HTTPURLResponse(
            url: URL(string: "https://httpbin.org/get")!,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Type": "application/json; charset=utf-8"]
        )
        
        observer.send(value: ResponseProducerResult(request: nil, response: response, data: data, error: nil))
        observer.sendCompleted()
        
        XCTAssertEqual(result.value.count, 1)
        let event = result.value.first!
        XCTAssertTrue(event.isTerminating)
        let respWithError = event.error!
        XCTAssertTrue(respWithError.result.isFailure)
    }

}
