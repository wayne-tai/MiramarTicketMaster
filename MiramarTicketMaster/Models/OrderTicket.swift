//
//  OrderTicket.swift
//  MiramarTicketMaster
//
//  Created by 𝕎𝔸𝕐ℕ𝔼 on 2019/4/11.
//  Copyright © 2019 Wayne. All rights reserved.
//

import Foundation

class OrderTicket: Decodable {
	let result: Int
	let data: Data
	
	enum CodingKeys: String, CodingKey {
		case result = "Result"
		case data = "Data"
	}
}

extension OrderTicket {
	
	class Data: Decodable {
		let order: Order
		
		enum CodingKeys: String, CodingKey {
			case order = "Order"
		}
	}
	
	class Order: Decodable {
		let userSessionId: String
		let totalValueCents: Int
		
		enum CodingKeys: String, CodingKey {
			case userSessionId = "UserSessionId"
			case totalValueCents = "TotalValueCents"
		}
	}
}
