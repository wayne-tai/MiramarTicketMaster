//
//  Seats.swift
//  MiramarTicketMaster
//
//  Created by Wayne on 2018/3/28.
//  Copyright © 2018年 Wayne. All rights reserved.
//

import Foundation

struct Area: CBDecodableModel {
    let rows: [Row]
    let areaCategoryCode: String
    let description: String
    let numberOfSeats: Int
    
    enum ObjectKeys: String, CodingKey {
        case areas = "Areas"
    }
    
    enum CodingKeys: String, CodingKey {
        case rows = "Rows"
        case areaCategoryCode = "AreaCategoryCode"
        case description = "Description"
        case numberOfSeats = "NumberOfSeats"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        rows = try container.decode([Row].self, forKey: .rows)
        areaCategoryCode = try container.decode(String.self, forKey: .areaCategoryCode)
        description = try container.decode(String.self, forKey: .description)
        numberOfSeats = try container.decode(Int.self, forKey: .numberOfSeats)
    }
    
    internal static func areas(from data: Data) throws -> [Area] {
        return try CBDecodableModels<Area>.decodeInResultObject(from: data, objectKey: ObjectKeys.areas.stringValue).models
    }
}

struct Row: Decodable {
    let seats: [Seat]
    let physicalName: String?
    
    enum CodingKeys: String, CodingKey {
        case seats = "Seats"
        case physicalName = "PhysicalName"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        seats = try container.decode([Seat].self, forKey: .seats)
        physicalName = try container.decodeIfPresent(String.self, forKey: .physicalName) ?? nil
    }
}

class Seat: Decodable {
    let position: Position
    let id: String
    let status: Status
    let seatStyle: String
    var score: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case position = "Position"
        case id = "Id"
        case status = "Status"
        case seatStyle = "SeatStyle"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        position = try container.decode(Position.self, forKey: .position)
        id = try container.decode(String.self, forKey: .id)
        status = try container.decode(Status.self, forKey: .status)
        seatStyle = try container.decode(String.self, forKey: .seatStyle)
    }
    
    enum Status: String, Decodable {
        case empty = "Empty"
        case sold = "Sold"
        case reserved = "Reserved"
        case special = "Special"
        case house = "House"
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self)
            
            guard let status = Status(rawValue: value) else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "\'\(value)\' is not accepted.")
            }
            self = status
        }
    }
}

struct Position: Decodable {
    let areaNumber: Int
    let rowIndex: Int
    let columnIndex: Int
    
    enum CodingKeys: String, CodingKey {
        case areaNumber = "AreaNumber"
        case rowIndex = "RowIndex"
        case columnIndex = "ColumnIndex"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        areaNumber = try container.decode(Int.self, forKey: .areaNumber)
        rowIndex = try container.decode(Int.self, forKey: .rowIndex)
        columnIndex = try container.decode(Int.self, forKey: .columnIndex)
    }
}
