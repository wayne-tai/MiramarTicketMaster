//
//  OrderResult.swift
//  MiramarTicketMaster
//
//  Created by Wayne on 2018/3/31.
//  Copyright © 2018年 Wayne. All rights reserved.
//

import Foundation

struct OrderResult: CBDecodableModel {
    let vistaBookingNumber: String
    
    enum CodingKeys: String, CodingKey {
        case vistaBookingNumber = "VistaBookingNumber"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.cobinhoodContainer(withContainerKeyType: CodingKeys.self)
        vistaBookingNumber = try container.decode(String.self, forKey: .vistaBookingNumber)
    }
    
    internal static func result(from data: Data) throws -> OrderResult {
        return try OrderResult.decodeInResult(from: data)
    }
}
