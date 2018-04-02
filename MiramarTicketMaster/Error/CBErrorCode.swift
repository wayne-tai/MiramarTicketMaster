//
//  CBErrorCode.swift
//  Cobinhood
//
//  Created by 𝕎𝔸𝕐ℕ𝔼 on 2017/9/29.
//  Copyright © 2017年 Cobinhood Inc. All rights reserved.
//

import Foundation

struct CBErrorCode: RawRepresentable {
	
	var rawValue: String
	
	init?(rawValue: String) {
		self.rawValue = rawValue
	}
	
	init(_ rawValue: String) {
		self.rawValue = rawValue
	}
	
	var message: String {
		return rawValue.localized
	}
}

extension CBErrorCode: Codable {
	init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		let errorCode = try container.decode(String.self)
		self = CBErrorCode(errorCode)
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(self.rawValue)
	}
}

extension CBErrorCode {
	
	static let parameterError = CBErrorCode("parameter_error")
	
	static let emailExist = CBErrorCode("email_exist")
	
	static let unexpectedError = CBErrorCode("unexpected_error")
	
	static let invalidToken = CBErrorCode("invalid_token")
	
	static let emailAlreadyVerified = CBErrorCode("email_already_verified")
	
	static let emailNotExist = CBErrorCode("email_not_exist")
	
	// The same with emailAlreadyVerified??
	static let emailVerified = CBErrorCode("email_verified")
	
	static let tryAgainLater = CBErrorCode("try_again_later")
	
	static let emailNotVerified = CBErrorCode("email_not_verified")
	
	static let invalidPassword = CBErrorCode("invalid_password")
	
	static let authenticationError = CBErrorCode("authentication_error")
	
	static let phoneNumRequried = CBErrorCode("phone_num_requried")
	
	static let alreadyEnabled = CBErrorCode("already_enabled")
}
