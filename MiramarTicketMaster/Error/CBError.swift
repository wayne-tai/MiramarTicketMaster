//
//  CBError.swift
//  Cobinhood
//
//  Created by Wayne on 2017/9/14.
//  Copyright © 2017年 Cobinhood Inc. All rights reserved.
//

import Foundation
import Alamofire

// MARK: -
// MARK: Create API error
internal func apiError(_ reason: CBError.ApiReason) -> CBError {
	return .apiError(reason)
}

internal func apiRequestFailedError(_ statusCode: Int, errorCode: CBErrorCode, requestId: String?) -> CBError {
	return apiError(.requestFailed(statusCode: statusCode, errorCode: errorCode, requestId: requestId))
}

internal func errorPayload(_ errorCode: CBErrorCode, requestId: String?) -> CBError {
	return apiError(.errorPayload(errorCode: errorCode, requestId: requestId))
}

// MARK: -
// MARK: Create network error
internal func networkError(_ reason: CBError.NetworkReason) -> CBError {
	return .networkError(reason)
}

internal func requestFailedError(_ url: URL, statusCode: Int) -> CBError {
	return networkError(.requestFailed(url: url, statusCode: statusCode))
}

internal func timeoutError(_ url: URL) -> CBError {
	return networkError(.timeout(url: url))
}

internal func alamofireError(_ error: AFError) -> CBError {
	return networkError(.alamofire(error: error))
}

// MARK: -
// MARK: Create internal error
internal func internalError(_ reason: CBError.InternalReason) -> CBError {
	return .internalError(reason)
}

internal func responseMissingError(_ url: URL?) -> CBError {
	return internalError(.responseMissing(url: url))
}

internal func JSONDecodingFailedError(_ message: String) -> CBError {
	return internalError(.JSONDecodingFailed(description: message))
}

internal func noResultDataError(_ data: Data) -> CBError {
	return internalError(.noResultData(originalData: data))
}

internal func unknownError() -> CBError {
	return internalError(.unknown)
}

// MARK: -
internal enum CBError: Error {
	
	internal enum ApiReason {
		
		/// For all API request failed errors.
		///
		/// The 1st `Int` parameter is status code.
		/// The 2nd `CBErrorCode` parameter is error code received from server.
		/// The 3rd `String` parameter is request id received from server.
		case requestFailed(statusCode: Int, errorCode: CBErrorCode, requestId: String?)
		
		/// For all API error payload.
		/// This is only for error decoding and pass to `.requestFailed`.
		///
		/// The 1st parameter is `error_code`.
		/// The 2nd parameter is `request_id`.
		case errorPayload(errorCode: CBErrorCode, requestId: String?)
	}
	
	internal enum NetworkReason {
		case requestFailed(url: URL, statusCode: Int)
		case timeout(url: URL)
		case alamofire(error: AFError)
	}
	
	internal enum InternalReason {
		case noNetwork
		case responseMissing(url: URL?)
		case JSONDecodingFailed(description: String)
		case noResultData(originalData: Data)
		case unknown
	}
	
	case apiError(ApiReason)
	case networkError(NetworkReason)
	case internalError(InternalReason)
}

extension CBError {
	
	internal var isApiError: Bool {
		if case .apiError = self { return true }
		return false
	}
	
	internal var isNetworkError: Bool {
		if case .networkError = self { return true }
		return false
	}
	
	internal var isInternalError: Bool {
		if case .internalError = self { return true }
		return false
	}
}

extension CBError {
	
	internal var url: URL? {
		switch self {
		case .apiError(let reason):
			return reason.url
		case .networkError(let reason):
			return reason.url
		case .internalError(let reason):
			return reason.url
		}
	}
	
	internal var statusCode: Int? {
		switch self {
		case .apiError(let reason):
			return reason.statusCode
		default:
			return nil
		}
	}
	
	internal var message: String? {
		switch self {
		case .apiError(let reason):
			return reason.message
		case .networkError(let reason):
			return reason.message
		case .internalError(let reason):
			return reason.message
		}
	}
}

// MARK: -
extension CBError.ApiReason {
	
	internal var url: URL? {
		return nil
	}
	
	internal var statusCode: Int? {
		switch self {
		case .requestFailed(let code, _, _):
			return code
		case .errorPayload:
			return nil
		}
	}
	
	internal var message: String? {
		switch self {
		case .requestFailed(_, let errorCode, _):
			return errorCode.message
		case .errorPayload(let errorCode, _):
			return errorCode.message
		}
	}
	
	internal var errorCode: CBErrorCode {
		switch self {
		case .requestFailed(_, let errorCode, _):
			return errorCode
		case .errorPayload(let errorCode, _):
			return errorCode
		}
	}
	
	internal var requestId: String? {
		switch self {
		case .requestFailed(_, _, let requestId):
			return requestId
		case .errorPayload(_, let requestId):
			return requestId
		}
	}
}

// MARK: -
extension CBError.NetworkReason {
	
	internal var url: URL? {
		switch self {
		case .requestFailed(let url, _), .timeout(let url):
			return url
		case .alamofire(let error):
			return error.url
		}
	}
	
	internal var message: String? {
		switch self {
		case .requestFailed(_, let code):
			return "exchange_msg_request_failed_error".localized(with: code)
		case .timeout:
			return "exchange_msg_timeout_error".localized
		case .alamofire(let error):
			return error.errorDescription
		}
	}
}

// MARK: -
extension CBError.InternalReason {
	
	internal var url: URL? {
		switch self {
		case .responseMissing(let url):
			return url
		case .noNetwork, .JSONDecodingFailed, .noResultData, .unknown:
			return nil
		}
	}
	
	internal var message: String {
		switch self {
		case .noNetwork:
			return "exchange_msg_network_unreachable".localized
		case .responseMissing(let url):
			return "Response missing for url request path [\(String(describing: url?.absoluteString))]."
		case .JSONDecodingFailed(let message):
			return "JSON decode failed with reason: \(message)"
		case .noResultData(let data):
			return "Result data is not exists. Data string: \(data.utf8StringValue)"
		case .unknown:
			return "Unknown Error."
		}
	}
}

// MARK: -
// MARK: CBError Extensions for ApiReason

extension CBError {
	
	internal var errorCode: CBErrorCode? {
		guard let _message = self.message else {
			return nil
		}
		
		return CBErrorCode(_message)
	}
	
	internal var requestId: String? {
		switch self {
		case .apiError(let reason):
			return reason.requestId
		default:
			return nil
		}
	}
}

// MARK: -
// MARK: Protocol ErrorStringConvertible

internal protocol ErrorStringConvertible {
	
	var errorMessage: String? { get }
}

// MARK: CBError Extension for ErrorStringConvertible

extension CBError: ErrorStringConvertible {
	
	var errorMessage: String? {
		return message
	}
}

// MARK: -
// MARK: Decodable

extension CBError: CBDecodableModel {
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: SharedKeys.self)
		let payload = try container.decode(CBErrorApiReasonPayload.self, forKey: .error)
		let requestId = try container.decodeIfPresent(String.self, forKey: .requestId)
		
		self = errorPayload(payload.errorCode, requestId: requestId)
	}
	
	internal static func decode(from data: Data) throws -> CBError {
		return try wrapDecodable { try JSONDecoder().decode(self, from: data) }
	}
}

// MARK: -
// MARK: CBErrorApiReasonPayload

struct CBErrorApiReasonPayload: Codable {
	
	private(set) var errorCode: CBErrorCode
	
	enum CodingKeys: String, CodingKey {
		case errorCode = "error_code"
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		errorCode = try container.decode(CBErrorCode.self, forKey: .errorCode)
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(errorCode, forKey: .errorCode)
	}
}

