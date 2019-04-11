//
//  TicketType.swift
//  MiramarTicketMaster
//
//  Created by Wayne on 2018/3/28.
//  Copyright © 2018年 Wayne. All rights reserved.
//

import Foundation

struct TicketType: Decodable {
    let result: Int
    let data: Data
    
    enum CodingKeys: String, CodingKey {
        case result = "Result"
        case data = "Data"
    }
	
	var tickets: [Ticket] {
		return data.tickets
	}
}

extension TicketType {
    
    struct Data: Decodable {
        let tickets: [Ticket]
        
        enum CodingKeys: String, CodingKey {
            case tickets = "Tickets"
        }
    }
}

extension TicketType {
    
    struct Ticket: Decodable {
        let ticketTypeCode: String
        let loyaltyRecognitionSequence: Int
        let description: String
        let priceInCents: Int
        
        enum CodingKeys: String, CodingKey {
            case ticketTypeCode = "TicketTypeCode"
            case loyaltyRecognitionSequence = "LoyaltyRecognitionSequence"
            case description = "Description"
            case priceInCents = "PriceInCents"
        }
		
		func toOrderTicketType(with quantity: Int) -> Order.TicketType {
			let orderTicketType = Order.TicketType()
			orderTicketType.loyaltyRecognitionSequence = String(loyaltyRecognitionSequence)
			orderTicketType.qty = String(quantity)
			orderTicketType.priceInCents = String(priceInCents)
			orderTicketType.ticketTypeCode = ticketTypeCode
			return orderTicketType
		}
    }
}
