//
//  SignalProducer.swift
//  ReactiveAlamofire
//
//  Created by Fang-Pen Lin on 2/16/16.
//  Copyright © 2016 Envoy. All rights reserved.
//

import Foundation

import Alamofire
import ReactiveSwift
import Result

extension Alamofire.DataResponse: Error {}

public extension SignalProtocol where Value: ResponseProducerResultType, Error: ResponseProducerResultType {
    /**
        Parse the next response of `self` with given Alamofire ResponseSerializer
         - Parameter responseSerializer: the response serializer to apply on response from self signal
         - Returns: A Signal which produces Alamofire.Response with the desired format
     */
    
    func parseResponse<T: DataResponseSerializerProtocol>(_ responseSerializer: T) -> Signal<Alamofire.DataResponse<T.SerializedObject>, Alamofire.DataResponse<T.SerializedObject>> {
        return Signal { observer in
            return self.observe { event in
                var respValue: ResponseProducerResultType!
                switch event {
                case .interrupted:
                    observer.sendInterrupted()
                    return
                case .completed:
                    observer.sendCompleted()
                    return
                case .value(let value):
                    respValue = value
                    // We try to parse the response event the response has error, as looks like it's by design of Alamofire
                case .failed(let error):
                    respValue = error
                }
                let result = responseSerializer.serializeResponse(
                    respValue.request,
                    respValue.response,
                    respValue.data,
                    respValue.error
                )
                let resp = DataResponse<T.SerializedObject>(
                    request: respValue.request,
                    response: respValue.response,
                    data: respValue.data,
                    result: result
                )
                if (result.isSuccess) {
                    observer.send(value: resp)
                } else {
                    observer.send(error: resp)
                }
            }
        }
    }
}

public extension SignalProducerProtocol where Value: Alamofire.DataRequest, Error == NoError {
    /**
        Make a SignalProducer for generating response SignalProducer from self request of SignalProducer and return
         - Returns: A SignalProducer for generating response SignalProducer from request
     */
    
    func metaResponseProducer() -> SignalProducer<SignalProducer<ResponseProducerResult, ResponseProducerResult>, ResponseProducerResult> {
        return self
            .promoteErrors(ResponseProducerResult.self)
            .map { $0.responseProducer() }
    }
    
    /**
        Make a SignalProducer for generating response from self request of SignalProducer and return
         - Returns: A SignalProducer for generating response from request
     */
    
    func responseProducer(_ strategy: ReactiveSwift.FlattenStrategy = .concat) -> SignalProducer<ResponseProducerResult, ResponseProducerResult> {
        return self
            .metaResponseProducer()
            .flatten(strategy)
    }
}

public extension SignalProducerProtocol where Value: ResponseProducerResultType, Error: ResponseProducerResultType {
    /**
        Parse the next response of `self` with given Alamofire ResponseSerializer
         - Parameter responseSerializer: the response serializer to apply on responses from `self` SignalProducer
         - Returns: A SignalProducer which produces Alamofire.Response with the desired format
     */
    
    func parseResponse<T: DataResponseSerializerProtocol>(_ responseSerializer: T) -> SignalProducer<Alamofire.DataResponse<T.SerializedObject>, Alamofire.DataResponse<T.SerializedObject>> {
        return self.lift { signal in
            return signal.parseResponse(responseSerializer)
        }
    }
}
