//
//  Config.swift
//  MiramarTicketMaster
//
//  Created by 𝕎𝔸𝕐ℕ𝔼 on 2019/4/12.
//  Copyright © 2019 Wayne. All rights reserved.
//

import Foundation

struct Config {
	
//	var targetMovieName: String = "沙贊"
	
	var targetMovieName: String = "復仇者聯盟"
	
	var targetTicketType: String = "Adult"
	
	var targetTicketQuantity: Int = 2
	
	var targetSeats: [TargetSeatRange] = [
		TargetSeatRange(row: "M", range: 9...20),
		TargetSeatRange(row: "L", range: 9...20),
		TargetSeatRange(row: "N", range: 9...20),
		TargetSeatRange(row: "K", range: 9...20)
	]
	
	var targetMovieDateTimes: [Date] = {
		let dateTimeStrings = [
			"2019-04-16T19:00:00",
			"2019-04-27T19:00:00",
			"2019-04-28T19:00:00"
		]
		return dateTimeStrings.compactMap { $0.date }
	}()
	
	var sessionId: String = "DLS8JS79YUB6JLI3867ZSDAUHSA0KIOY"
}
