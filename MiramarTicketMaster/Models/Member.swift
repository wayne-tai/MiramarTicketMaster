//
//  Member.swift
//  MiramarTicketMaster
//
//  Created by 𝕎𝔸𝕐ℕ𝔼 on 2019/4/10.
//  Copyright © 2019 Wayne. All rights reserved.
//

import Foundation

struct Member: Decodable {
	let result: Int
	let data: MemberInfo
	
	enum CodingKeys: String, CodingKey {
		case result = "Result"
		case data = "Data"
	}
	
	var info: MemberInfo {
		return data
	}
}

struct MemberInfo: Decodable {
	let memberAuthData: String
	
	enum CodingKeys: String, CodingKey {
		case memberAuthData = "MemberAuthData"
	}
	
	var authData: String {
		return memberAuthData
	}
}
