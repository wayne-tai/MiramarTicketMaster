//
//  Payment.swift
//  MiramarTicketMaster
//
//  Created by 𝕎𝔸𝕐ℕ𝔼 on 2019/4/11.
//  Copyright © 2019 Wayne. All rights reserved.
//

import Foundation

class Payment {
	var optionalMemberId: String = ""
	var customerEmail: String = ""
	var customerPhone: String = ""
	var customerName: String = ""
	var sessionId: String = ""
	var paymentValueCents: String = ""
	
	var dictionaryValue: [String: Any] {
		return [
			"UserSessionId": sessionId,
			"PaymentInfo": [
				"PaymentValueCents": paymentValueCents
			],
			"OptionalMemberId": optionalMemberId,
			"CustomerEmail": customerEmail,
			"CustomerPhone": customerPhone,
			"CustomerName": customerName
		]
	}
}
