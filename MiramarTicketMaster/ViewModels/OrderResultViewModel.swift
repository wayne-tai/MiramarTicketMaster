//
//  OrderResultViewModel.swift
//  MiramarTicketMaster
//
//  Created by 𝕎𝔸𝕐ℕ𝔼 on 2019/4/13.
//  Copyright © 2019 Wayne. All rights reserved.
//

import Foundation

class OrderResultViewModel {
	
	let orderTicket: OrderTicket
	
	init(orderTicket: OrderTicket) {
		self.orderTicket = orderTicket
	}
	
	var movieName: String {
		return orderTicket.session.altFilmTitle
	}
	
	var movieDate: String {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
		formatter.timeZone = TimeZone.init(identifier: "UTC")
		guard let date = formatter.date(from: orderTicket.session.showingRealDateTime) else {
			return orderTicket.session.showingRealDateTime
		}
		
		formatter.dateStyle = .medium
		formatter.timeStyle = .short
		formatter.timeZone = TimeZone.current
		return formatter.string(from: date)
	}
	
	var movieSeats: String {
		return orderTicket.session.tickets
			.map { "\($0.seatRowId)\($0.seatNumber)" }
			.joined(separator: " ")
	}
}
