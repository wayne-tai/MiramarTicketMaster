//
//  RxAlamofire.swift
//  Cobinhood
//
//  Created by 𝕎𝔸𝕐ℕ𝔼 on 2017/12/1.
//  Copyright © 2017年 Cobinhood Inc. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

// MARK: Manager - Extension of Manager

protocol RxAlamofireRequest {
	
	func responseWith(completionHandler: @escaping (RxAlamofireResponse) -> Void)
	func resume()
	func cancel()
}

protocol RxAlamofireResponse {
	var error: Error? {get}
}

extension DefaultDataResponse: RxAlamofireResponse {}

extension UploadRequest: RxAlamofireRequest {
	func responseWith(completionHandler: @escaping (RxAlamofireResponse) -> Void) {
		response { (response) in
			completionHandler(response)
		}
	}
}

extension Reactive where Base: SessionManager {
	
	func upload(to url: URL, headers: HTTPHeaders? = nil, multipartFormData: @escaping (MultipartFormData) -> Void) -> Observable<UploadRequest> {
		return Observable.create { (observer) -> Disposable in
			self.base.upload(multipartFormData: multipartFormData, to: url, headers: headers) { (encodingResult) in
				switch encodingResult {
				case .success(let uploadRequest, _, _):
					
					observer.on(.next(uploadRequest))
					uploadRequest.responseWith(completionHandler: { (response) in
						if let error = response.error {
							observer.on(.error(error))
						} else {
							observer.on(.completed)
						}
					})
					
					if !self.base.startRequestsImmediately {
						uploadRequest.resume()
					}
					
				case let .failure(error):
					observer.on(.error(error))
				}
			}
			
			return Disposables.create()
		}
	}
}

// MARK: -
// MARK: DataRequest - Extension of DataRequest

typealias ResponsedData = DataResponse<Data>

extension Reactive where Base: DataRequest {
	
	internal func responseData() -> Observable<ResponsedData> {
		return Observable.create { observer in
			let request = self.base
			
			request.responseData { response in
				observer.on(.next(response))
				observer.on(.completed)
			}
			
			return Disposables.create {
				request.cancel()
			}
		}
	}
}

// MARK: -
// MARK: DataResponse - Extension of DataResponse

extension DataResponse: ReactiveCompatible {
}

extension Reactive where Base == DataResponse<Data> {
	
	/// Validate the response and returns a `Observable` instance of Data object
	///
	/// - Returns: An `Observable` instance of Data object
	internal func validate() -> Observable<Data> {
		return Observable.create { (observer) -> Disposable in
			
			// Ensure `HTTPURLResponse` and its `url` are not `nil`
			guard let response = self.base.response, let url = response.url else {
				observer.onError(responseMissingError(self.base.request?.url))
				return Disposables.create()
			}
			let statusCode = response.statusCode
			
			switch self.base.result {
			case .success(let data):
				
				/// If status code is 2xx
				if StatusCode.Category.success.contains(statusCode) {
					observer.onNext(data)
					observer.onCompleted()
					
				}
				/// Error handle for other status code
				else {
					
					do {
						// Retrieve error info from server
						let err = try CBError.decode(from: data)
						
						// Retrieve error code from server response reason
						// Typically, it won't be nil
						// Otherwise, something is goning wrong
						guard case let .apiError(.errorPayload(errorCode, requestId)) = err else {
							throw unknownError()
						}
						
						// Submit the error
						observer.onError(apiRequestFailedError(statusCode, errorCode: errorCode, requestId: requestId))
						
					} catch {
						/// Internal error due to JSON decodeing failed
						if case let CBError.internalError(internalError) = error, case .JSONDecodingFailed = internalError {
							observer.onError(error)
						}
						else {
							/// Network error due to unable to reach our server
							observer.onError(requestFailedError(url, statusCode: statusCode))
						}
					}
				}
				
			case .failure(let error):
				
				// Throws the error out.
				observer.onError(error)
			}
			
			return Disposables.create()
		}
	}
}

