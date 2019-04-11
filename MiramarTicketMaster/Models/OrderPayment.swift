//
//  OrderPayment.swift
//  MiramarTicketMaster
//
//  Created by 𝕎𝔸𝕐ℕ𝔼 on 2019/4/12.
//  Copyright © 2019 Wayne. All rights reserved.
//

import Foundation

class OrderPayment: Decodable {
	let result: Int
	
	enum CodingKeys: String, CodingKey {
		case result = "Result"
	}
}

