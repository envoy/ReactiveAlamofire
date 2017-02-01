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
    var request: URLRequest? { get }
    var response: HTTPURLResponse? { get }
    var data: Data? { get }
    var error: NSError? { get }
    init(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: NSError?)
}

/// Object for response producer result
open class ResponseProducerResult: ResponseProducerResultType {
    open var request: URLRequest?
    open var response: HTTPURLResponse?
    open var data: Data?
    open var error: NSError?
    
    required public init(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: NSError?) {
        self.request = request
        self.response = response
        self.data = data
        self.error = error
    }
}

extension ResponseProducerResult: Error {}

public extension Alamofire.Request {
    /// Producer for generating response
    typealias ResponseProducer = SignalProducer<ResponseProducerResult, ResponseProducerResult>
    
    /**
        Make a SignalProducer for generating response from `self` request and return
         - Returns: A SignalProducer for generating response from request
     */
    
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
