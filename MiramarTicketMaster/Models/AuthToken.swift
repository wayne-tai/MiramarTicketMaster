//
//  AuthToken.swift
//  MiramarTicketMaster
//
//  Created by 𝕎𝔸𝕐ℕ𝔼 on 2019/4/10.
//  Copyright © 2019 Wayne. All rights reserved.
//

import Foundation

struct AuthToken: Decodable {
	let result: Int
	let data: String
	
	enum CodingKeys: String, CodingKey {
		case result = "Result"
		case data = "Data"
	}
	
	var token: String {
		return data
	}
}
