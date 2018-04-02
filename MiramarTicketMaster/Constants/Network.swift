//
//  ApiRequestHeader.swift
//  Cobinhood
//
//  Created by Wayne on 2017/8/15.
//  Copyright © 2017年 Cobinhood Inc. All rights reserved.
//

import Foundation


struct ApiRequestHeader {
	static let Auth = "Authorization"
	static let ApiKey = "api-key"
	static let DeviceId = "device_id"
	static let Nonce = "nonce"
	static let Origin = "Origin"
}

struct StatusCode {
	
	struct Http {
		static let ok: Int					= 200
		static let created: Int				= 201
		static let accepted: Int			= 202
		
		static let badRequest: Int			= 400
		static let unauthorized: Int		= 401
		static let requestFailed: Int		= 402
		static let forbidden: Int			= 403
		static let notFound: Int			= 404
		static let conflict: Int			= 409
		static let tooManyRequests: Int		= 429
		
		static let internalServerError: Int	= 500
		
		/// Need to retry in this case
		static let badGateway: Int			= 502
		
		static let serviceUnavailable: Int	= 503
		static let gatewayTimeout: Int		= 504
	}
	
	/// The following status code belong to `InternalError`
	struct Internal {
		static let noNetwork: Int			= 1001
		static let JSONParseError: Int		= 1002
		static let unknownError: Int		= 1003
	}
	
	/// Category for status codes
	struct Category {
		static let success: CountableRange		= 200 ..< 300
		static let clientError: CountableRange	= 400 ..< 500
		static let serverError: CountableRange	= 500 ..< 600
	}
}
