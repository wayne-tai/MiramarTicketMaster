//
//  OrderConfirm.swift
//  MiramarTicketMaster
//
//  Created by Wayne on 2018/3/31.
//  Copyright © 2018年 Wayne. All rights reserved.
//

import Foundation

struct OrderConfirm: CBDecodableModel {
    let ticketTypeList: [OrderConfirm.TicketType]
    let cinemaId: String
    let cinemaCName: String
    let cinemaEName: String
    let seatId: String
    let movieCName: String
    let movieEName: String
    let movieShowTime: String
    let totalValue: Int
    let bookingFeeValue: Int
    let totalOrderCount: Int
    let timeSpan: Int
    
    enum CodingKeys: String, CodingKey {
        case ticketTypeList = "TicketTypeList"
        case cinemaId = "CinemaId"
        case cinemaCName = "CinemaCName"
        case cinemaEName = "CinemaEName"
        case seatId = "SeatId"
        case movieCName = "MovieCName"
        case movieEName = "MovieEName"
        case movieShowTime = "MovieShowTime"
        case totalValue = "TotalValue"
        case bookingFeeValue = "BookingFeeValue"
        case totalOrderCount = "TotalOrderCount"
        case timeSpan = "TimeSpan"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.cobinhoodContainer(withContainerKeyType: CodingKeys.self)
        ticketTypeList = try container.decode([OrderConfirm.TicketType].self, forKey: .ticketTypeList)
        cinemaId = try container.decode(String.self, forKey: .cinemaId)
        cinemaCName = try container.decode(String.self, forKey: .cinemaCName)
        cinemaEName = try container.decode(String.self, forKey: .cinemaEName)
        seatId = try container.decode(String.self, forKey: .seatId)
        movieCName = try container.decode(String.self, forKey: .movieCName)
        movieEName = try container.decode(String.self, forKey: .movieEName)
        movieShowTime = try container.decode(String.self, forKey: .movieShowTime)
        totalValue = try container.decode(Int.self, forKey: .totalValue)
        bookingFeeValue = try container.decode(Int.self, forKey: .bookingFeeValue)
        totalOrderCount = try container.decode(Int.self, forKey: .totalOrderCount)
        timeSpan = try container.decode(Int.self, forKey: .timeSpan)
    }
    
    internal static func orderConfirm(from data: Data) throws -> OrderConfirm {
        return try OrderConfirm.decodeInResult(from: data)
    }
}

extension OrderConfirm {
    
    struct TicketType: Decodable {
        let ticketDescriptEn: String
        let ticketDescriptCht: String
        let quantity: Int
        let ticketSumPrice: Int
        
        enum ObjectKeys: String, CodingKey {
            case ticketTypeList = "TicketTypeList"
        }
        
        enum CodingKeys: String, CodingKey {
            case ticketDescriptEn = "TicketDescriptEn"
            case ticketDescriptCht = "TicketDescriptCht"
            case quantity = "Quantity"
            case ticketSumPrice = "TicketSumPrice"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            ticketDescriptEn = try container.decode(String.self, forKey: .ticketDescriptEn)
            ticketDescriptCht = try container.decode(String.self, forKey: .ticketDescriptCht)
            quantity = try container.decode(Int.self, forKey: .quantity)
            ticketSumPrice = try container.decode(Int.self, forKey: .ticketSumPrice)
        }
    }
}
