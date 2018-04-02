//
//  TicketType.swift
//  MiramarTicketMaster
//
//  Created by Wayne on 2018/3/28.
//  Copyright © 2018年 Wayne. All rights reserved.
//

import Foundation

struct TicketType: CBDecodableModel {
    let ticketTypeCode: String
    let ticketTypeDescriptEn: String
    let ticketTypeDescriptCht: String
    let ticketPrice: Int
    
    enum ObjectKeys: String, CodingKey {
        case ticketTypeList = "TicketTypeList"
    }
    
    enum CodingKeys: String, CodingKey {
        case ticketTypeCode = "TicketTypeCode"
        case ticketTypeDescriptEn = "TicketTypeDescriptEn"
        case ticketTypeDescriptCht = "TicketTypeDescriptCht"
        case ticketPrice = "TicketPrice"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        ticketTypeCode = try container.decode(String.self, forKey: .ticketTypeCode)
        ticketTypeDescriptEn = try container.decode(String.self, forKey: .ticketTypeDescriptEn)
        ticketTypeDescriptCht = try container.decode(String.self, forKey: .ticketTypeDescriptCht)
        ticketPrice = try container.decode(Int.self, forKey: .ticketPrice)
    }
    
    internal static func ticketTypes(from data: Data) throws -> [TicketType] {
        return try CBDecodableModels<TicketType>.decodeInResultObject(from: data, objectKey: ObjectKeys.ticketTypeList.stringValue).models
    }
}
