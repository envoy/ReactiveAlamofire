//
//  SignalProducer.swift
//  ReactiveAlamofire
//
//  Created by Fang-Pen Lin on 2/16/16.
//  Copyright © 2016 Envoy. All rights reserved.
//

import Foundation

import Alamofire
import ReactiveCocoa


// TODO: these ResponseProducerResult can actually be replaced with Alamofire.Response extends a protocol
// however, it seems there is a bug in Swift or what, the linking is not working
// See this stackoverflow I posted
// http://stackoverflow.com/questions/35442764/undefined-symbols-for-architecture-x86-64-for-extension-with-an-alamofire-reques

/// Type for ResponseProducer result
public protocol ResponseProducerResultType {
    var request: NSURLRequest? { get }
    var response: NSHTTPURLResponse? { get }
    var data: NSData? { get }
    var error: NSError? { get }
    init(request: NSURLRequest?, response: NSHTTPURLResponse?, data: NSData?, error: NSError?)
}

/// Object for response producer result
public class ResponseProducerResult: ResponseProducerResultType {
    public var request: NSURLRequest?
    public var response: NSHTTPURLResponse?
    public var data: NSData?
    public var error: NSError?
    
    required public init(request: NSURLRequest?, response: NSHTTPURLResponse?, data: NSData?, error: NSError?) {
        self.request = request
        self.response = response
        self.data = data
        self.error = error
    }
}

extension ResponseProducerResult: ErrorType {}

public extension Alamofire.Request {
    /// Producer for generating response
    typealias ResponseProducer = SignalProducer<ResponseProducerResult, ResponseProducerResult>
    
    /**
        Make a SignalProducer for generating response from `self` request and return
         - Returns: A SignalProducer for generating response from request
     */
    @warn_unused_result(message="Did you forget to call `start` on the producer?")
    func responseProducer() -> SignalProducer<ResponseProducerResult, ResponseProducerResult> {
        return SignalProducer<ResponseProducerResult, ResponseProducerResult> { observer, disposable in
            switch self.task.state {
            case .Suspended:
                self.task.resume()
            case .Canceling:
                observer.sendInterrupted()
                return
            default:
                break
            }
            self.response { request, response, data, error in
                let resp = ResponseProducerResult(
                    request: request,
                    response: response,
                    data: data,
                    error: error
                )
                guard error == nil else {
                    observer.sendFailed(resp)
                    return
                }
                observer.sendNext(resp)
                observer.sendCompleted()
            }
            disposable.addDisposable {
                self.cancel()
            }
        }
    }
}
