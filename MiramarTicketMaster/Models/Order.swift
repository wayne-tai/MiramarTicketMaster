//
//  Order.swift
//  MiramarTicketMaster
//
//  Created by 𝕎𝔸𝕐ℕ𝔼 on 2019/4/11.
//  Copyright © 2019 Wayne. All rights reserved.
//

import Foundation

class Order {
	var memberId: String = ""
	var ticketTypes: [TicketType] = []
	var cinemaId: String = ""
	var selectedSeats: [SelectedSeat] = []
	var userSessionId: String = ""
	var sessionId: String = ""
	
	var dictionaryValue: [String: Any] {
		return [
			"MemberId": memberId,
			"TicketTypes": ticketTypes.map { $0.dictionaryValue },
			"CinemaId": cinemaId,
			"SelectedSeats": selectedSeats.map { $0.dictionaryValue },
			"UserSessionId": userSessionId,
			"SessionId": sessionId
		]
	}
}

extension Order {
	
	class TicketType {
		var loyaltyRecognitionSequence: String = ""
		var qty: String = ""
		var priceInCents: String = ""
		var ticketTypeCode: String = ""
		
		var dictionaryValue: [String: String] {
			return [
				"LoyaltyRecognitionSequence": loyaltyRecognitionSequence,
				"Qty": qty,
				"PriceInCents": priceInCents,
				"TicketTypeCode": ticketTypeCode
			]
		}
	}
	
	class SelectedSeat {
		var areaCategoryCode: String = ""
		var areaNumber: String = ""
		var rowIndex: String = ""
		var columnIndex: String = ""
		
		var dictionaryValue: [String: String] {
			return [
				"AreaCategoryCode": areaCategoryCode,
				"AreaNumber": areaNumber,
				"RowIndex": rowIndex,
				"ColumnIndex": columnIndex
			]
		}
	}
}
