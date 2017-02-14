# ReactiveAlamofire

[![Build Status](https://travis-ci.org/envoy/ReactiveAlamofire.svg?branch=master)](https://travis-ci.org/envoy/ReactiveAlamofire)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/envoy/ReactiveAlamofire)
[![GitHub license](https://img.shields.io/github/license/envoy/ReactiveAlamofire.svg)](https://github.com/envoy/ReactiveAlamofire/blob/master/LICENSE)

[Alamofire](https://github.com/Alamofire/Alamofire) 4 integration for [ReactiveSwift](https://github.com/ReactiveCocoa/ReactiveSwift)

## Example

```Swift
import Alamofire
import ReactiveSwift
import ReactiveAlamofire
import Result

SignalProducer<DataRequest, NoError>.attempt {
    return .success(Alamofire.request("http://httpbin.org/get?foo=bar"))
}
    .responseProducer()  // Make the Request SignalProducer to be a Response SignalProducer
    .parseResponse(DataRequest.jsonResponseSerializer()) // Parse response with JSONResponseSerializer
    .startWithResult { result in
        switch result {
        case .failure(let error):
            print("failed, error=\(error)")
        case .success(let resp):
            print(resp.result.value ?? "No data")
        }
    }
```

here comes the output

```
{
    args =     {
        foo = bar;
    };
    headers =     {
        Accept = "*/*";
        "Accept-Encoding" = "gzip;q=1.0, compress;q=0.5";
        "Accept-Language" = "en-US;q=1.0";
        Host = "httpbin.org";
        "User-Agent" = "Unknown/Unknown (Unknown; OS Version 9.3 (Build 13E5181d))";
    };
    origin = "111.111.111.111";
    url = "http://httpbin.org/get?foo=bar";
}
```

voilà!

You can call `responseProducer(responseSerializer: ResponseSerializerType)` with any `ResponseSerializer` for `Alamofire` to parse the response.


## Install with Carthage

To install with [Carthage](https://github.com/Carthage/Carthage), add ReactiveAlamofire to your Cartfile:

```
github "envoy/ReactiveAlamofire"
```

## Install with CocoaPod

To install with [CocoaPod](https://cocoapods.org), add ReactiveAlamofire to your Podfile:

```
pod 'ReactiveAlamofire', '~> 2.0.0'
```
