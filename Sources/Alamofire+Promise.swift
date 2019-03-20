@_exported import Alamofire
import Foundation
#if !PMKCocoaPods
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
    public func response(_: PMKNamespacer, queue: DispatchQueue? = nil) -> Promise<(URLRequest, HTTPURLResponse, Data)> {
        return Promise { seal in
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
    public func response<T: DataResponseSerializerProtocol>(queue: DispatchQueue? = nil, responseSerializer: T) -> Promise<(value: T.SerializedObject, response: PMKAlamofireDataResponse)> {
        return Promise { seal in
            response(queue: queue, responseSerializer: responseSerializer) { response in
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
    public func responseData(queue: DispatchQueue? = nil) -> Promise<(data: Data, response: PMKAlamofireDataResponse)> {
        return Promise { seal in
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
    public func responseString(queue: DispatchQueue? = nil, encoding: String.Encoding? = nil) -> Promise<(string: String, response: PMKAlamofireDataResponse)> {
        return Promise { seal in
            responseString(queue: queue, encoding: encoding) { response in
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
        return Promise { seal in
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

#if swift(>=3.2)
    /**
     Returns a Promise for a Decodable
     Adds a handler to be called once the request has finished.
     
     - Parameter queue: DispatchQueue, by default nil
     - Parameter decoder: JSONDecoder, by default JSONDecoder()
     */
    public func responseDecodable<T: Decodable>(queue: DispatchQueue? = nil, decoder: JSONDecoder = JSONDecoder()) -> Promise<T> {
        return Promise { seal in
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
        return Promise { seal in
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
    /// Adds a handler to be called once the request has finished.
    public func response<T: DownloadResponseSerializerProtocol>(queue: DispatchQueue? = nil, responseSerializer: T) -> Promise<(value: T.SerializedObject, response: PMKAlamofireDownloadResponse)> {
        return Promise { seal in
            response(queue: queue, responseSerializer: responseSerializer) { response in
                switch response.result {
                case .success(let value):
                    seal.fulfill((value, PMKAlamofireDownloadResponse(response)))
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }

    /// Adds a handler to be called once the request has finished.
    public func responseData(queue: DispatchQueue? = nil) -> Promise<(data: Data, response: PMKAlamofireDownloadResponse)> {
        return Promise { seal in
            responseData(queue: queue) { response in
                switch response.result {
                case .success(let value):
                    seal.fulfill((value, PMKAlamofireDownloadResponse(response)))
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }

    /// Adds a handler to be called once the request has finished.
    public func responseString(queue: DispatchQueue? = nil) -> Promise<(string: String, response: PMKAlamofireDownloadResponse)> {
        return Promise { seal in
            responseString(queue: queue) { response in
                switch response.result {
                case .success(let value):
                    seal.fulfill((value, PMKAlamofireDownloadResponse(response)))
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }

    /// Adds a handler to be called once the request has finished.
    public func responseJSON(queue: DispatchQueue? = nil, options: JSONSerialization.ReadingOptions = .allowFragments) -> Promise<(json: Any, response: PMKAlamofireDownloadResponse)> {
        return Promise { seal in
            responseJSON(queue: queue, options: options) { response in
                switch response.result {
                case .success(let value):
                    seal.fulfill((value, PMKAlamofireDownloadResponse(response)))
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
        metrics = rawrsp.metrics
        serializationDuration = rawrsp.serializationDuration
    }

    /// The URL request sent to the server.
    public let request: URLRequest?

    /// The server's response to the URL request.
    public let response: HTTPURLResponse?

    /// The data returned by the server.
    public let data: Data?

    /// The final metrics of the response.
    public let metrics: URLSessionTaskMetrics?

    /// The time taken to serialize the response.
    public let serializationDuration: TimeInterval
}

/// Alamofire.DownloadResponse, but without the `result`, since the Promise represents the `Result`
public struct PMKAlamofireDownloadResponse {
    public init<T>(_ rawrsp: Alamofire.DownloadResponse<T>) {
        request = rawrsp.request
        response = rawrsp.response
        fileURL = rawrsp.fileURL
        resumeData = rawrsp.resumeData
        metrics = rawrsp.metrics
        serializationDuration = rawrsp.serializationDuration
    }

    /// The URL request sent to the server.
    public let request: URLRequest?

    /// The server's response to the URL request.
    public let response: HTTPURLResponse?

    /// The final destination URL of the data returned from the server after it is moved.
    public let fileURL: URL?

    /// The resume data generated if the request was cancelled.
    public let resumeData: Data?

    /// The final metrics of the response.
    public let metrics: URLSessionTaskMetrics?

    /// The time taken to serialize the response.
    public let serializationDuration: TimeInterval
}
