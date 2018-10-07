@_exported import Alamofire
import Foundation
#if !PMKCocoaPods
import PromiseKit
#endif

/// Extend Request to be a CancellableTask
extension Request: CancellableTask {
    /// `true` if the Alamofire request was successfully cancelled, `false` otherwise
    public var isCancelled: Bool {
        return task?.state == .canceling
    }
}

/**
 To import the `Alamofire` category:

     use_frameworks!
     pod "PromiseKit/Alamofire"

 And then in your sources:

     import PromiseKit
 */
extension Alamofire.DataRequest {
    /// Adds a handler to be called once the request has finished.
    public func response(_: PMKNamespacer, queue: DispatchQueue? = nil) -> Promise<(URLRequest, HTTPURLResponse, Data)> {
        return Promise<(URLRequest, HTTPURLResponse, Data)>(cancellableTask: self) { seal in
            response(queue: queue) { rsp in
                if let error = rsp.error {
                    seal.reject(error)
                } else if let a = rsp.request, let b = rsp.response, let c = rsp.data {
                    seal.fulfill((a, b, c))
                } else {
                    seal.reject(PMKError.invalidCallingConvention)
                }
            }
        }
    }

    /// Adds a handler to be called once the request has finished.
    public func responseData(queue: DispatchQueue? = nil) -> Promise<(data: Data, response: PMKAlamofireDataResponse)> {
        return Promise<(data: Data, response: PMKAlamofireDataResponse)>(cancellableTask: self) { seal in
            responseData(queue: queue) { response in
                switch response.result {
                case .success(let value):
                    seal.fulfill((value, PMKAlamofireDataResponse(response)))
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }

    /// Adds a handler to be called once the request has finished.
    public func responseString(queue: DispatchQueue? = nil) -> Promise<(string: String, response: PMKAlamofireDataResponse)> {
        return Promise<(string: String, response: PMKAlamofireDataResponse)>(cancellableTask: self) { seal in
            responseString(queue: queue) { response in
                switch response.result {
                case .success(let value):
                    seal.fulfill((value, PMKAlamofireDataResponse(response)))
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }

    /// Adds a handler to be called once the request has finished.
    public func responseJSON(queue: DispatchQueue? = nil, options: JSONSerialization.ReadingOptions = .allowFragments) -> Promise<(json: Any, response: PMKAlamofireDataResponse)> {
        return Promise<(json: Any, response: PMKAlamofireDataResponse)>(cancellableTask: self) { seal in
            responseJSON(queue: queue, options: options) { response in
                switch response.result {
                case .success(let value):
                    seal.fulfill((value, PMKAlamofireDataResponse(response)))
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }

    /// Adds a handler to be called once the request has finished.
    public func responsePropertyList(queue: DispatchQueue? = nil, options: PropertyListSerialization.ReadOptions = PropertyListSerialization.ReadOptions()) -> Promise<(plist: Any, response: PMKAlamofireDataResponse)> {
        return Promise<(plist: Any, response: PMKAlamofireDataResponse)>(cancellableTask: self) { seal in
            responsePropertyList(queue: queue, options: options) { response in
                switch response.result {
                case .success(let value):
                    seal.fulfill((value, PMKAlamofireDataResponse(response)))
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }

#if swift(>=3.2)
    /**
     Returns a Promise for a Decodable
     Adds a handler to be called once the request has finished.
     
     - Parameter queue: DispatchQueue, by default nil
     - Parameter decoder: JSONDecoder, by default JSONDecoder()
     */
    public func responseDecodable<T: Decodable>(queue: DispatchQueue? = nil, decoder: JSONDecoder = JSONDecoder()) -> Promise<T> {
        return Promise<T>(cancellableTask: self) { seal in
            responseData(queue: queue) { response in
                switch response.result {
                case .success(let value):
                    do {
                        seal.fulfill(try decoder.decode(T.self, from: value))
                    } catch {
                        seal.reject(error)
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
 
     /**
     Returns a Promise for a Decodable
     Adds a handler to be called once the request has finished.
     
     - Parameter queue: DispatchQueue, by default nil
     - Parameter decoder: JSONDecoder, by default JSONDecoder()
     */
    public func responseDecodable<T: Decodable>(_ type: T.Type, queue: DispatchQueue? = nil, decoder: JSONDecoder = JSONDecoder()) -> Promise<T> {
        return Promise<T>(cancellableTask: self) { seal in
            responseData(queue: queue) { response in
                switch response.result {
                case .success(let value):
                    do {
                        seal.fulfill(try decoder.decode(type, from: value))
                    } catch {
                        seal.reject(error)
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
#endif
}

extension Alamofire.DownloadRequest {
    public func response(_: PMKNamespacer, queue: DispatchQueue? = nil) -> Promise<DefaultDownloadResponse> {
        return Promise<DefaultDownloadResponse>(cancellableTask: self) { seal in
            response(queue: queue) { response in
                if let error = response.error {
                    seal.reject(error)
                } else {
                    seal.fulfill(response)
                }
            }
        }
    }

    /// Adds a handler to be called once the request has finished.
    public func responseData(queue: DispatchQueue? = nil) -> Promise<DownloadResponse<Data>> {
        return Promise<DownloadResponse<Data>>(cancellableTask: self) { seal in
            responseData(queue: queue) { response in
                switch response.result {
                case .success:
                    seal.fulfill(response)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
}


/// Alamofire.DataResponse, but without the `result`, since the Promise represents the `Result`
public struct PMKAlamofireDataResponse {
    public init<T>(_ rawrsp: Alamofire.DataResponse<T>) {
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

//////////////////////////////////////////////////////////// Cancellable wrappers

extension Alamofire.DataRequest {
    /// Wraps Alamofire.Response from Alamofire.response(queue:) as CancellablePromise<(Foundation.URLRequest, Foundation.HTTPURLResponse, Foundation.Data)>
    public func cancellableResponse(_: PMKNamespacer, queue: DispatchQueue? = nil) -> CancellablePromise<(URLRequest, HTTPURLResponse, Data)> {
        return cancellable(response(.promise, queue: queue))
    }
    
    /// Wraps Alamofire.DataResponse from Alamofire.responseData(queue:) as CancellablePromise<(Foundation.Data, PromiseKit.PMKAlamofireDataResponse)>
    public func cancellableResponseData(queue: DispatchQueue? = nil) -> CancellablePromise<(data: Data, response: PMKAlamofireDataResponse)> {
        return cancellable(responseData(queue: queue))
    }
    
    /// Wraps the response from Alamofire.responseString(queue:) as CancellablePromise<(String, PromiseKit.PMKAlamofireDataResponse)>.  Uses the default encoding to decode the string data.
    public func cancellableResponseString(queue: DispatchQueue? = nil) -> CancellablePromise<(string: String, response: PMKAlamofireDataResponse)> {
        return cancellable(responseString(queue: queue))
    }
    
    /// Wraps the response from Alamofire.responseJSON(queue:options:) as CancellablePromise<(Any, PromiseKit.PMKAlamofireDataResponse)>.  By default, the JSON decoder allows fragments, therefore 'Any' can be any standard JSON type (NSArray, NSDictionary, NSString, NSNumber, or NSNull).  If the received JSON is not a fragment then 'Any' will be either an NSArray or NSDictionary.
    public func cancellableResponseJSON(queue: DispatchQueue? = nil, options: JSONSerialization.ReadingOptions = .allowFragments) -> CancellablePromise<(json: Any, response: PMKAlamofireDataResponse)> {
        return cancellable(responseJSON(queue: queue, options: options))
    }
    
    /// Wraps the response from Alamofire.responsePropertyList(queue:options:) as CancellablePromise<(Any, PromiseKit.PMKAlamofireDataResponse)>.  Uses Foundation.PropertyListSerialization to deserialize the property list.  'Any' is an NSArray or NSDictionary containing only the types NSData, NSString, NSArray, NSDictionary, NSDate, and NSNumber.
    public func cancellableResponsePropertyList(queue: DispatchQueue? = nil, options: PropertyListSerialization.ReadOptions = PropertyListSerialization.ReadOptions()) -> CancellablePromise<(plist: Any, response: PMKAlamofireDataResponse)> {
        return cancellable(responsePropertyList(queue: queue, options: options))
    }
    
    #if swift(>=3.2)
    /// Wraps the response from Alamofire.responseDecodable(queue:) as CancellablePromise<Decodable>.  The Decodable is used to decode the incoming JSON data.
    public func cancellableResponseDecodable<T: Decodable>(queue: DispatchQueue? = nil, decoder: JSONDecoder = JSONDecoder()) -> CancellablePromise<T> {
        return cancellable(responseDecodable(queue: queue, decoder: decoder))
    }
    
    /// Wraps the response from Alamofire.responseDecodable() as CancellablePromise<(Decodable)>.  The Decodable is used to decode the incoming JSON data.
    public func cancellableResponseDecodable<T: Decodable>(_ type: T.Type, queue: DispatchQueue? = nil, decoder: JSONDecoder = JSONDecoder()) -> CancellablePromise<T> {
        return cancellable(responseDecodable(type, queue: queue, decoder: decoder))
    }
    #endif
}

extension Alamofire.DownloadRequest {
    /// Wraps Alamofire.Reponse.DefaultDownloadResponse from Alamofire.DownloadRequest.response(queue:) as CancellablePromise<Alamofire.Reponse.DefaultDownloadResponse>
    public func cancellableResponse(_: PMKNamespacer, queue: DispatchQueue? = nil) -> CancellablePromise<DefaultDownloadResponse> {
        return cancellable(response(.promise, queue: queue))
    }
    
    /// Wraps Alamofire.Reponse.DownloadResponse<Data> from Alamofire.DownloadRequest.responseData(queue:) as CancellablePromise<Alamofire.Reponse.DownloadResponse<Data>>
    public func cancellableResponseData(queue: DispatchQueue? = nil) -> CancellablePromise<DownloadResponse<Data>> {
        return cancellable(responseData(queue: queue))
    }
}
