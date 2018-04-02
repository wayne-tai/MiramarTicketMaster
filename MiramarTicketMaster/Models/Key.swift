//
//  Key.swift
//  MiramarTicketMaster
//
//  Created by Wayne on 2018/3/27.
//  Copyright © 2018年 Wayne. All rights reserved.
//

import Foundation

struct Key: CBDecodableModel {
    let result: Bool
    let data: String
    let resultCode: Int
    
    enum ObjectKeys: String, CodingKey {
        case key = "Key"
    }
    
    enum CodingKeys: String, CodingKey {
        case result = "Result"
        case data = "Data"
        case resultCode = "ResultCode"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.cobinhoodContainer(for: ObjectKeys.key, containerKeyType: CodingKeys.self)
        result = try container.decode(Bool.self, forKey: .result)
        data = try container.decode(String.self, forKey: .data)
        resultCode = try container.decode(Int.self, forKey: .resultCode)
    }
    
    internal static func key(from data: Data) throws -> Key {
        return try Key.decodeInResultObject(from: data)
    }
}
