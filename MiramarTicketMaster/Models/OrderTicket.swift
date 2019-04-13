//
//  OrderTicket.swift
//  MiramarTicketMaster
//
//  Created by 𝕎𝔸𝕐ℕ𝔼 on 2019/4/11.
//  Copyright © 2019 Wayne. All rights reserved.
//

import Foundation

class OrderTicket: Decodable {
	let result: Int
	let data: Data
	
	enum CodingKeys: String, CodingKey {
		case result = "Result"
		case data = "Data"
	}
	
	var session: Order.Session {
		return data.order.sessions.first!
	}
}

extension OrderTicket {
	
	class Data: Decodable {
		let order: Order
		
		enum CodingKeys: String, CodingKey {
			case order = "Order"
		}
	}
	
	class Order: Decodable {
		let userSessionId: String
		let totalValueCents: Int
		let totalOrderCount: Int
		let sessions: [Session]
		
		enum CodingKeys: String, CodingKey {
			case userSessionId = "UserSessionId"
			case totalValueCents = "TotalValueCents"
			case totalOrderCount = "TotalOrderCount"
			case sessions = "Sessions"
		}
	}
}

extension OrderTicket.Order {
	
	struct Session: Decodable {
		let altFilmTitle: String
		let showingRealDateTime: String
		let tickets: [Ticket]
		
		enum CodingKeys: String, CodingKey {
			case altFilmTitle = "AltFilmTitle"
			case showingRealDateTime = "ShowingRealDateTime"
			case tickets = "Tickets"
		}
	}
}

extension OrderTicket.Order.Session {
	
	struct Ticket: Decodable {
		let seatNumber: String
		let seatRowId: String
		
		enum CodingKeys: String, CodingKey {
			case seatNumber = "SeatNumber"
			case seatRowId = "SeatRowId"
		}
	}
}
