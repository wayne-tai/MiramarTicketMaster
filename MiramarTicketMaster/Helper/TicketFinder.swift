//
//  TicketFinder.swift
//  MiramarTicketMaster
//
//  Created by 𝕎𝔸𝕐ℕ𝔼 on 2019/4/11.
//  Copyright © 2019 Wayne. All rights reserved.
//

import Foundation

class TicketFinder {
	
	let targetTicketQuantity: Int
	
	init(targetTicketQuantity: Int) {
		self.targetTicketQuantity = targetTicketQuantity
	}
	
	func ticket(from ticketType: TicketType) -> TicketType.Ticket? {
		guard let ticket = ticketType.tickets.first(where: { $0.description == "Adult" }) else { return nil }
		return ticket
	}
}
