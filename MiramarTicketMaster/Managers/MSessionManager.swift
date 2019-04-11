//
//  MSessionManager.swift
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

class MSessionManager: SessionManager, Requestable {
	
	// Singleton
    internal static let shared: MSessionManager = {
        let configuration = URLSessionConfiguration.background(withIdentifier: "com.cobinhood.background")
        configuration.urlCache = nil // no cache
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.timeoutIntervalForRequest = 15 // request timeout
        configuration.timeoutIntervalForResource = 15 // request timeout
        
        return MSessionManager(configuration: configuration)
    }()
	
	fileprivate lazy var dispatchQueue: DispatchQueue = {
		let queue = DispatchQueue(label: "com.miramar.ticker.master", qos: .default, attributes: .concurrent)
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
	                      urlString:	String,
	                      parameters:	Parameters? = nil,
	                      encoding:		ParameterEncoding = URLEncoding.default,
	                      headers:		HTTPHeaders? = nil) -> Single<Data> {
		
		// Changes `subscribeOn(MainScheduler.instance)` to `concurrentScheduler` for preventing the
		// whole chain performs on main thread
		// Reference from: https://stackoverflow.com/a/37986481
		let urlString = Environments.Url.Domain + urlString
		return self.rx.request(method, urlString, parameters: parameters, encoding: encoding, headers: headers)
			.observeOn(scheduler)
			
			/// Transform from `DataRequest` to `DataResponse`
			.flatMap { $0.rx.responseData() }
			
			/// Validate received `DataResponse`
			.flatMap{ $0.rx.validate() }
		
			.asSingle()
			
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
	func request(_ method: HTTPMethod, urlString: String, parameters: Parameters?, encoding: ParameterEncoding, headers: HTTPHeaders?) -> Single<Data>
	
}
