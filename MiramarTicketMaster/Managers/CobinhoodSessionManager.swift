//
//  CobinhoodSessionManager.swift
//  Cobinhood
//
//  Created by 𝕎𝔸𝕐ℕ𝔼 on 2017/8/15.
//  Copyright © 2017年 Cobinhood Inc. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import RxCocoa
import RxAlamofire
import SwifterSwift

fileprivate let maxAttempts: Int = 3

fileprivate let retryDelay = 3

class CobinhoodSessionManager: SessionManager, Requestable {
    
    /// Data Providers
    internal var networkReachabilityProvider: NetworkReachabilityProvider? = NetworkReachabilityManager.shared
	
	internal static var baseURLString: String {
		return Environments.Url.Base
	}
	
	/// Stores current on-going requests.
	/// Determines network activity indicator visible by current request count.
	private var onGoingRequests: Int = 0 {
		didSet {
			DispatchQueue.main.async { UIApplication.shared.isNetworkActivityIndicatorVisible = (self.onGoingRequests > 0) }
		}
	}
	
	// Singleton
    internal static let shared: CobinhoodSessionManager = {
        let configuration = URLSessionConfiguration.background(withIdentifier: "com.cobinhood.background")
        configuration.urlCache = nil // no cache
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.timeoutIntervalForRequest = 15 // request timeout
        configuration.timeoutIntervalForResource = 15 // request timeout
        
        return CobinhoodSessionManager(configuration: configuration)
    }()
	
	fileprivate lazy var dispatchQueue: DispatchQueue = {
		let queue = DispatchQueue(label: "com.cobinhood.apiManager", qos: .default, attributes: .concurrent)
		return queue
	}()
	
	fileprivate lazy var scheduler: ConcurrentDispatchQueueScheduler = {
		let scheduler = ConcurrentDispatchQueueScheduler(queue: dispatchQueue)
		return scheduler
	}()
	
	/// Create a request and response with `Data`
	///
	/// - Parameters:
	///   - method: `HTTPMethod` instance
	///   - urlString: A `String` object for url path without host
	///   - parameters:A dictionary containing all necessary options
	///   - encoding: The kind of encoding used to process parameters
	///   - headers: A dictionary containing all the additional headers
	/// - Returns: An `Observable` of `Data` object
	internal func request(_ method:		HTTPMethod,
						  endpoint:		String,
	                      urlString:	String,
	                      parameters:	Parameters? = nil,
	                      encoding:		ParameterEncoding = URLEncoding.default,
	                      headers:		HTTPHeaders? = nil) -> Observable<Data> {
		
		// Check if network is reachable
		guard networkReachabilityProvider?.isReachable ?? false else {
			return Observable.error(internalError(.noNetwork))
		}
		
		/// Increase current on going requests
		onGoingRequests += 1
		
		// Changes `subscribeOn(MainScheduler.instance)` to `concurrentScheduler` for preventing the
		// whole chain performs on main thread
		// Reference from: https://stackoverflow.com/a/37986481
		let urlString = endpoint + urlString
		return self.rx.request(method, urlString, parameters: parameters, encoding: encoding, headers: headers)
			.observeOn(scheduler)
			
			/// Transform from `DataRequest` to `DataResponse`
			.flatMap { $0.rx.responseData() }
			
			/// Validate received `DataResponse`
			.flatMap{ $0.rx.validate() }
			
			/// Handles thrown error
			.catchError { (error) -> Observable<Data> in
				/// If error is `CBError`, means this error is handled, then just throw again.
				if error is CBError {
					throw error
				}
				
				/// If URL in error is not available, then throws the error.
				guard let url = error.failingURL else {
					throw error
				}
				
				// Handle error for network timeout
				if error.code == NSURLErrorTimedOut {
					throw timeoutError(url)
				}

				// Handle error from `Alamofire`
				if let error = error as? AFError {
					throw alamofireError(error)
				}

				// Handle other network error
				throw requestFailedError(url, statusCode: error.code)
			}
			
			///Log information and validte if the error code is authentication error
			.do(
				onNext: { [weak self] json in
					guard let _self = self else {
						return
					}
					
					_self.onGoingRequests = max(0, (_self.onGoingRequests - 1))
					
					/// Log success information
					log.info("[API Success] \(urlString)")
					
			},
				onError: { [weak self] error in
					guard let _self = self else {
						return
					}
					
					_self.onGoingRequests = max(0, (_self.onGoingRequests - 1))
					
					/// Log error information
					log.error(_self.message(by: error, urlString: urlString))
			})
			
			/// Retry if needed
//			.retryWhen(retryHandler)
	}
	
	/// Upload with multipart form data.
	///
	/// - Parameters:
	///   - urlString: A `String` value for url path without host
	///   - headers: A `Dictionary` containing all the additional headers
	///   - multipartFormData: A block that handles the multipart form data.
	/// - Returns: An `Observable` of `Data` object
	internal func upload(to urlString: String,
	                     headers: HTTPHeaders? = nil,
	                     multipartFormData: @escaping (MultipartFormData) -> Void) -> Observable<Data> {
		
		/// Check if network is reachable
		guard networkReachabilityProvider?.isReachable ?? false else {
			return Observable.error(internalError(.noNetwork))
		}
		
		/// Increase current on going requests
		onGoingRequests += 1
		
		/// Create `URL`
		guard let url = URL(string: CobinhoodSessionManager.baseURLString + urlString) else {
			return Observable.error(unknownError())
		}
		
		return self.rx.upload(to: url, headers: headers, multipartFormData: multipartFormData)
			.observeOn(scheduler)
			
			/// Transform from `DataRequest` to `DataResponse`
			.flatMap { $0.rx.responseData() }
			
			/// Validate received `DataResponse`
			.flatMap{ $0.rx.validate() }
			
			/// Handles thrown error
			.catchError { (error) -> Observable<Data> in
				/// If error is `CBError`, means this error is handled, then just throw again.
				if error is CBError {
					throw error
				}
				
				/// If URL in error is not available, then throws the error.
				guard let url = error.failingURL else {
					throw error
				}
				
				// Handle error for network timeout
				if error.code == NSURLErrorTimedOut {
					throw timeoutError(url)
				}
				
				// Handle error from `Alamofire`
				if let error = error as? AFError {
					throw alamofireError(error)
				}
				
				// Handle other network error
				throw requestFailedError(url, statusCode: error.code)
			}
			
			///Log information and validte if the error code is authentication error
			.do(
				onNext: { [weak self] json in
					guard let _self = self else {
						return
					}
					
					_self.onGoingRequests = max(0, (_self.onGoingRequests - 1))
					
					/// Log success information
					log.info("[API Success] \(urlString)")
					
			},
				onError: { [weak self] error in
					guard let _self = self else {
						return
					}
					
					_self.onGoingRequests = max(0, (_self.onGoingRequests - 1))
					
					/// Log error information
					log.error(_self.message(by: error, urlString: urlString))
					
			})
			
			/// Retry if needed
//			.retryWhen(retryHandler)
	}
	
	private lazy var retryHandler: (Observable<Error>) -> Observable<Int> = { e in
		return e.flatMapWithIndex { (error, attempt) -> Observable<Int> in
			print("Retry with attempting: \(attempt)")
			
			/// Ensure current attempt is under max limit
			guard attempt < maxAttempts else {
				return Observable.error(error)
			}
			
			/// Check if current error is need to retry
			guard self.shoudRetry(for: error) else {
				return Observable.error(error)
			}
			
			return Observable<Int>.timer(Double(retryDelay), scheduler: self.scheduler).take(1)
		}
	}
	
	private func shoudRetry(for error: Error) -> Bool {
		/// Ensure the received error is `CBError`
		/// Otherwise, not to retry
		guard let cbErr = error as? CBError else {
			return false
		}
		
		if case let .apiError(reason) = cbErr, reason.statusCode == StatusCode.Http.badRequest {
			return true
		}
		
		if case let .networkError(reason) = cbErr, case let .alamofire(afErr) = reason {
			return afErr.isResponseSerializationError
		}
		
		return false
	}
	
	private func message(by error: Error, urlString: String) -> String {
		
		guard let cbErr = error as? CBError else {
			return "[API Failure] \(error.localizedDescription)"
		}
		
		var errorMessage = "[API Failure] \(String(describing: urlString))"
		
		if let statusCode = cbErr.statusCode {
			errorMessage += ", statusCode: \(statusCode)"
		}
		
		if let message = cbErr.message {
			errorMessage += ", message: \(message)"
		}
		
		if let requestId = cbErr.requestId {
			errorMessage += ", requestId: \(requestId)"
		}
		
		return errorMessage
	}
}

// MARK: -
// MARK: Get Response

/// Protocol `Requestable` defines an interface that has ability to send an URL request.
internal protocol Requestable {
	
	/// Returns an `Observable` instance of Data.
	///
	/// - Parameters:
	///   - method: Alamofire method object
	///	  - endpoint: A `String` value for endpoint
	///   - urlString: A `String` value for url path
	///   - parameters: A dictionary containing all necessary options
	///   - encoding: The kind of encoding used to process parameters
	///   - headers: A dictionary containing all the additional headers
	/// - Returns: An observable of the `Data` object
	func request(_ method: HTTPMethod, endpoint: String, urlString: String, parameters: Parameters?, encoding: ParameterEncoding, headers: HTTPHeaders?) -> Observable<Data>
	
	/// Upload with multipart form data.
	///
	/// - Parameters:
	///   - urlString: A `String` value for url path without host
	///   - headers: A `Dictionary` containing all the additional headers
	///   - multipartFormData: A block that handles the multipart form data.
	/// - Returns: An `Observable` of `Data` object
	func upload(to urlString: String, headers: HTTPHeaders?, multipartFormData: @escaping (MultipartFormData) -> Void) -> Observable<Data>
	
}
