//
//  Config.swift
//  MiramarTicketMaster
//
//  Created by 𝕎𝔸𝕐ℕ𝔼 on 2019/4/12.
//  Copyright © 2019 Wayne. All rights reserved.
//

import Foundation
import UIKit

struct Config {
    
    let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }
		
    var targetMovieName: String = "復仇者聯盟"
	
	var targetTicketType: String = "Adult"
	
	var targetTicketQuantity: Int = 2
    
    var screenFilter: ScreenFilter = .exclude([.imax, .threeD])
	
	var targetSeats: [TargetSeatRange] = [
		TargetSeatRange(row: "M", range: 9...20),
		TargetSeatRange(row: "L", range: 9...20),
		TargetSeatRange(row: "N", range: 9...20),
		TargetSeatRange(row: "K", range: 9...20)
	]
	
	var targetMovieDateTimes: [Date] = {
		let dateTimeStrings = [
			"2019-05-01T10:30:00",
			"2019-04-30T10:30:00"
		]
		return dateTimeStrings.compactMap { $0.date }
	}()
	
	var sessionId: String = "RYW4JFGFVLG68K7M11M3Y2WIQWMMHAC5"
}

enum ScreenFilter {
    case include(Condition)
    case exclude(Condition)
    
    func validate(with value: String) -> Bool {
        do {
            switch self {
            case .include(let condition):
                try condition.included(by: value)
            case .exclude(let condition):
                try condition.excluded(by: value)
            }
            return true
        
        } catch {
            return false
        }
    }
}

extension ScreenFilter {
    
    struct Condition: OptionSet {
        let rawValue: Int
        let value: String
        
        init(rawValue: Int) {
            self.rawValue = rawValue
            self.value = ""
        }
        
        init(rawValue: Int, value: String) {
            self.rawValue = rawValue
            self.value = value
        }
        
        func included(by value: String) throws {
            if contains(.imax) {
                guard value.include(condition: .imax) else { throw ConditionError.notIncluded }
            }
            if contains(.threeD) {
                guard value.include(condition: .threeD) else { throw ConditionError.notIncluded }
            }
            if contains(.normal) {
                guard value.include(condition: .normal) else { throw ConditionError.notIncluded }
            }
        }
        
        func excluded(by value: String) throws {
            if contains(.imax) {
                guard value.exclude(condition: .imax) else { throw ConditionError.notExcluded }
            }
            if contains(.threeD) {
                guard value.exclude(condition: .threeD) else { throw ConditionError.notExcluded }
            }
            if contains(.normal) {
                guard value.exclude(condition: .normal) else { throw ConditionError.notExcluded }
            }
        }
        
        static let imax = Condition(rawValue: 1 << 0, value: .imax)
        static let threeD = Condition(rawValue: 1 << 1, value: .threeD)
        static let normal = Condition(rawValue: 1 << 2, value: .normal)
    }
    
    enum ConditionError: Error {
        case notIncluded
        case notExcluded
    }
}

extension String {
    static let imax = "IMAX"
    static let threeD = "3D"
    static let normal = "標準"
    
    func include(condition: ScreenFilter.Condition) -> Bool {
        guard contains(condition.value) else { return false }
        return true
    }
    
    func exclude(condition: ScreenFilter.Condition) -> Bool {
        guard !contains(condition.value) else { return false }
        return true
    }
}
