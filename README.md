# ReactiveAlamofire

[![Build Status](https://travis-ci.org/envoy/ReactiveAlamofire.svg?branch=master)](https://travis-ci.org/envoy/ReactiveAlamofire)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/envoy/ReactiveAlamofire)
[![GitHub license](https://img.shields.io/github/license/envoy/ReactiveAlamofire.svg)](https://github.com/envoy/ReactiveAlamofire/blob/master/LICENSE)

[Alamofire](https://github.com/Alamofire/Alamofire) 3 integration for [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa) 4

## Example

```Swift
import Alamofire
import ReactiveCocoa
import ReactiveAlamofire
import Result

SignalProducer<Request, NoError> { observer, _ in
    observer.sendNext(Alamofire.request(.GET, "http://httpbin.org/get?foo=bar"))
}
    .responseProducer()  // Make the Alamofire.Request to a ResponseProducer (SignalProducer)
    .parseResponse(Request.JSONResponseSerializer()) // Parse response with JSONResponseSerializer
    .startWithNext { resp in
        print(resp.result.value)
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
