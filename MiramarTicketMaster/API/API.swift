//
//  API.swift
//  Cobinhood
//
//  Created by Wayne on 2017/9/12.
//  Copyright © 2017年 Cobinhood Inc. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

internal class API {
	
	fileprivate var sessionManager: Requestable
			
	fileprivate var disposeBag = DisposeBag()
	
	// Singleton
	static let shared: API = {
		return API(with: CobinhoodSessionManager.shared)
	}()
	
	init(with sessionManager: Requestable) {
		self.sessionManager = sessionManager
	}
	
	// MARK: Set Dependencies
	
	internal func set(sessionManager: Requestable) {
		self.sessionManager = sessionManager
	}
	
	// MARK: Send Request
	
	internal static func request(_ method:		HTTPMethod,
								 endpoint:		String = CobinhoodSessionManager.baseURLString,
	                             urlString:		String,
	                             parameters:	Parameters? = nil,
	                             encoding:		ParameterEncoding = URLEncoding.default,
	                             headers:		HTTPHeaders? = nil) -> Observable<Data> {
		
		return self.shared.sessionManager.request(method, endpoint: endpoint, urlString: urlString, parameters: parameters, encoding: encoding, headers: headers)
	}
	
	internal static func upload(to urlString: String,
	                            headers: HTTPHeaders? = nil,
	                            multipartFormData: @escaping (MultipartFormData) -> Void) -> Observable<Data> {
		
		return self.shared.sessionManager.upload(to: urlString, headers: headers, multipartFormData: multipartFormData)
	}
	
	static var disposeBag: DisposeBag {
		return shared.disposeBag
	}
	
}

typealias DataResult = Result<Data>
typealias EmptyResult = Result<Swift.Void>

// MARK: -
// MARK: Parameter Enums

extension API {
    
}
