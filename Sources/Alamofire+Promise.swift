@_exported import Alamofire
import Foundation
#if !COCOAPODS
import PromiseKit
#endif

/**
 To import the `Alamofire` category:

     use_frameworks!
     pod "PromiseKit/Alamofire"

 And then in your sources:

     import PromiseKit
 */
extension Alamofire.DataRequest {
    /// Adds a handler to be called once the request has finished.
    public func response(queue: DispatchQueue? = nil) -> Promise<(URLRequest, HTTPURLResponse, Data)> {
        return Promise { fulfill, reject in
            response(queue: queue) { rsp in
                if let error = rsp.error {
                    reject(error)
                } else if let a = rsp.request, let b = rsp.response, let c = rsp.data {
                    fulfill((a, b, c))
                } else {
                    reject(PMKError.invalidCallingConvention)
                }
            }
        }
    }

    /// Adds a handler to be called once the request has finished.
    public func responseData(queue: DispatchQueue? = nil) -> Promise<Data> {
        return Promise { fulfill, reject in
            responseData(queue: queue) { response in
                switch response.result {
                case .success(let value):
                    fulfill(value)
                case .failure(let error):
                    reject(error)
                }
            }
        }
    }

    /// Adds a handler to be called once the request has finished.
    public func responseString(queue: DispatchQueue? = nil) -> Promise<String> {
        return Promise { fulfill, reject in
            responseString(queue: queue) { response in
                switch response.result {
                case .success(let value):
                    fulfill(value)
                case .failure(let error):
                    reject(error)
                }
            }
        }
    }

    /// Adds a handler to be called once the request has finished.
    public func responseJSON(queue: DispatchQueue? = nil, options: JSONSerialization.ReadingOptions = .allowFragments) -> Promise<Any> {
        return Promise { fulfill, reject in
            responseJSON(queue: queue, options: options, completionHandler: { response in
                switch response.result {
                case .success(let value):
                    fulfill(value)
                case .failure(let error):
                    reject(error)
                }
            })
        }
    }

    /// Adds a handler to be called once the request has finished. Provides access to the detailed response object.
    ///    request.responseJSON(with: .response).then { json, response in }
    public func responseJSON(with: PMKAlamofireOptions, options: JSONSerialization.ReadingOptions = .allowFragments, queue: DispatchQueue? = nil) -> Promise<(Any, PMKDataResponse)> {
        return Promise { fulfill, reject in
            responseJSON(queue: queue, options: options, completionHandler: { response in
                switch response.result {
                case .success(let value):
                    fulfill((value, PMKDataResponse(response)))
                case .failure(let error):
                    reject(error)
                }
            })
        }
    }


    /// Adds a handler to be called once the request has finished and the resulting JSON is rooted at a dictionary.
    public func responseJsonDictionary(queue: DispatchQueue? = nil, options: JSONSerialization.ReadingOptions = .allowFragments) -> Promise<[String: Any]> {
        return Promise { fulfill, reject in
            responseJSON(queue: queue, options: options, completionHandler: { response in
                switch response.result {
                case .success(let value):
                    if let value = value as? [String: Any] {
                        fulfill(value)
                    } else {
                        reject(JSONError.unexpectedRootNode(value))
                    }
                case .failure(let error):
                    reject(error)
                }
            })
        }

    }

    /// Adds a handler to be called once the request has finished.
    public func responsePropertyList(queue: DispatchQueue? = nil, options: PropertyListSerialization.ReadOptions = PropertyListSerialization.ReadOptions()) -> Promise<Any> {
        return Promise { fulfill, reject in
            responsePropertyList(queue: queue, options: options) { response in
                switch response.result {
                case .success(let value):
                    fulfill(value)
                case .failure(let error):
                    reject(error)
                }
            }
        }
    }
}

extension Alamofire.DownloadRequest {
    /// Adds a handler to be called once the request has finished.
    public func responseData(queue: DispatchQueue? = nil) -> Promise<DownloadResponse<Data>> {
        return Promise { fulfill, reject in
            responseData(queue: queue) { response in
                switch response.result {
                case .success:
                    fulfill(response)
                case .failure(let error):
                    reject(error)
                }
            }
        }
    }
}



public enum PMKAlamofireOptions {
    case response
}


public struct PMKDataResponse {
    fileprivate init(_ rawrsp: Alamofire.DataResponse<Any>) {
        request = rawrsp.request
        response = rawrsp.response
        data = rawrsp.data
        timeline = rawrsp.timeline
    }

    /// The URL request sent to the server.
    public let request: URLRequest?

    /// The server's response to the URL request.
    public let response: HTTPURLResponse?

    /// The data returned by the server.
    public let data: Data?

    /// The timeline of the complete lifecycle of the request.
    public let timeline: Timeline
}
