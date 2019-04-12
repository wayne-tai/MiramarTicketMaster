//
//  TicketFinder.swift
//  MiramarTicketMaster
//
//  Created by 𝕎𝔸𝕐ℕ𝔼 on 2019/4/11.
//  Copyright © 2019 Wayne. All rights reserved.
//

import Foundation

class TicketFinder {
	
    var targetTicketType: String
	let targetTicketQuantity: Int
	
    init(targetTicketQuantity: Int, targetTicketType: String) {
        self.targetTicketType = targetTicketType
		self.targetTicketQuantity = targetTicketQuantity
	}
	
	func ticket(from ticketType: TicketType) -> TicketType.Ticket? {
		guard let ticket = ticketType.tickets.first(where: { $0.description == self.targetTicketType }) else { return nil }
		return ticket
	}
}
