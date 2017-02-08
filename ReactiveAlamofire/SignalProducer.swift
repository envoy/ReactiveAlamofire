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
import Result

extension Alamofire.DataResponse: Error {}

public extension SignalType where Value: ResponseProducerResultType, Error: ResponseProducerResultType {
    /**
        Parse the next response of `self` with given Alamofire ResponseSerializer
         - Parameter responseSerializer: the response serializer to apply on response from self signal
         - Returns: A Signal which produces Alamofire.Response with the desired format
     */
    
    func parseResponse<T: ResponseSerializerType>(_ responseSerializer: T) -> Signal<Alamofire.Response<T.SerializedObject, T.ErrorObject>, Alamofire.Response<T.SerializedObject, T.ErrorObject>> {
        return Signal { observer in
            return self.observe { event in
                var respValue: ResponseProducerResultType!
                switch event {
                case .Interrupted:
                    observer.sendInterrupted()
                    return
                case .Completed:
                    observer.sendCompleted()
                    return
                case .Next(let value):
                    respValue = value
                    // We try to parse the response event the response has error, as looks like it's by design of Alamofire
                case .Failed(let error):
                    respValue = error
                }
                let result = responseSerializer.serializeResponse(
                    respValue.request,
                    respValue.response,
                    respValue.data,
                    respValue.error
                )
                let resp = Response<T.SerializedObject, T.ErrorObject>(
                    request: respValue.request,
                    response: respValue.response,
                    data: respValue.data,
                    result: result
                )
                if (result.isSuccess) {
                    observer.sendNext(resp)
                } else {
                    observer.sendFailed(resp)
                }
            }
        }
    }
}

public extension SignalProducerType where Value: Alamofire.Request, Error == NoError {
    /**
        Make a SignalProducer for generating response SignalProducer from self request of SignalProducer and return
         - Returns: A SignalProducer for generating response SignalProducer from request
     */
    
    func metaResponseProducer() -> SignalProducer<SignalProducer<ResponseProducerResult, ResponseProducerResult>, ResponseProducerResult> {
        return self
            .promoteErrors(ResponseProducerResult)
            .map { $0.responseProducer() }
    }
    
    /**
        Make a SignalProducer for generating response from self request of SignalProducer and return
         - Returns: A SignalProducer for generating response from request
     */
    
    func responseProducer(_ strategy: ReactiveCocoa.FlattenStrategy = .Concat) -> SignalProducer<ResponseProducerResult, ResponseProducerResult> {
        return self
            .metaResponseProducer()
            .flatten(strategy)
    }
}

public extension SignalProducerType where Value: ResponseProducerResultType, Error: ResponseProducerResultType {
    /**
        Parse the next response of `self` with given Alamofire ResponseSerializer
         - Parameter responseSerializer: the response serializer to apply on responses from `self` SignalProducer
         - Returns: A SignalProducer which produces Alamofire.Response with the desired format
     */
    
    func parseResponse<T: ResponseSerializerType>(_ responseSerializer: T) -> SignalProducer<Alamofire.Response<T.SerializedObject, T.ErrorObject>, Alamofire.Response<T.SerializedObject, T.ErrorObject>> {
        return self.lift { signal in
            return signal.parseResponse(responseSerializer)
        }
    }
}
