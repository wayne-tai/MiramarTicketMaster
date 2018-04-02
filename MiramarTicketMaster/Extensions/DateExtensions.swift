//
//  DateExtensions.swift
//  Cobinhood
//
//  Created by Hao Chang on 25/09/2017.
//  Copyright © 2017 Cobinhood Inc. All rights reserved.
//

import Foundation

enum DateFormat:String {
    case date = "yyyy-MM-dd"
    case time = "HH:mm:ss"
    case dateTime = "yyyy-MM-dd HH:mm:ss"
    case exchangeTickerView = "MM/dd h:mm a"
    case campaignCell = "yyyy/M/dd HH:mm (zzz)"
}

extension Date {
    func string(withFormat format: String) -> String {
        let formatter = DateFormatter()
		formatter.timeZone = TimeZone.current
		formatter.locale = Locale.current
        formatter.dateFormat = format//"M/dd hh:mm a"
        return formatter.string(from: self)
    }
	
	enum TicketMasterDateFormat {
		static let `default` = "yyyy-MM-dd'T'HH:mm:ss"
	}
	
	init?(fromDateString dateString: String, format: String = Date.TicketMasterDateFormat.default) {
		let formatter = DateFormatter()
		formatter.timeZone = TimeZone.current
		formatter.dateFormat = format
		
		guard let date = formatter.date(from: dateString) else {
			return nil
		}
		self = date
	}
    
    func stringDate() -> String {
        return string(withFormat: DateFormat.date.rawValue)
    }
    
    func stringTime() -> String {
        return string(withFormat: DateFormat.time.rawValue)
    }
    
    func stringDateTime() -> String {
        return string(withFormat: DateFormat.dateTime.rawValue)
    }
    
    func stringForExchangeTickerView() -> String {
        return string(withFormat: DateFormat.exchangeTickerView.rawValue)
    }
    
    func stringForCampaignCell() -> String {
        return string(withFormat: DateFormat.campaignCell.rawValue)
    }
}
