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
	let data: Data
	
	enum CodingKeys: String, CodingKey {
		case result = "Result"
		case data = "Data"
	}
	
	var memberAuthData: String {
		return data.memberAuthData
	}
    
    var memberId: String {
        return data.loyaltyMember.memberId
    }
    
    var fullName: String {
        return data.loyaltyMember.fullName
    }
    
    var email: String {
        return data.loyaltyMember.email
    }
    
    var mobilePhone: String {
        return data.loyaltyMember.mobilePhone
    }
}

extension Member {
    
    struct Data: Decodable {
        let memberAuthData: String
        let loyaltyMember: LoyaltyMember
        
        enum CodingKeys: String, CodingKey {
            case memberAuthData = "MemberAuthData"
            case loyaltyMember = "LoyaltyMember"
        }
    }
}

extension Member.Data {
    
    struct LoyaltyMember: Decodable {
        let fullName: String
        let memberId: String
        let email: String
        let mobilePhone: String
        
        enum CodingKeys: String, CodingKey {
            case fullName = "FullName"
            case memberId = "MemberId"
            case email = "Email"
            case mobilePhone = "MobilePhone"
        }
    }
}


