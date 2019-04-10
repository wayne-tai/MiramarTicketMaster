//
//  NetworkService.swift
//  MiramarTicketMaster
//
//  Created by 𝕎𝔸𝕐ℕ𝔼 on 2019/4/10.
//  Copyright © 2019 Wayne. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

enum Encoding {
	case url, json
	
	fileprivate var object: ParameterEncoding {
		switch self {
		case .url: return URLEncoding.default
		case .json: return JSONEncoding.default
		}
	}
}

class NetworkService {
	
	private let sessionManager: Requestable
	
	init(sessionManager: Requestable = MSessionManager.shared) {
		self.sessionManager = sessionManager
	}
	
	internal let platform: String = "iOS"
	
	internal func request(
		_ method: HTTPMethod,
		urlString: String,
		parameters: Parameters? = nil,
		encoding: Encoding = .url,
		headers: HTTPHeaders? = nil) -> Single<Data> {
		
		let encodingObject = encoding.object
		return sessionManager.request(
			method,
			urlString: urlString,
			parameters: parameters,
			encoding: encodingObject,
			headers: headers
		)
	}
}

extension Dictionary where Key == String, Value == String {
	
	fileprivate static func += (lhs: inout Dictionary, rhs: Dictionary) {
		rhs.forEach { lhs[$0] = $1 }
	}
}

typealias EmptyResult = Result<Swift.Void>
