//
//  SeatPlan.swift
//  MiramarTicketMaster
//
//  Created by 𝕎𝔸𝕐ℕ𝔼 on 2019/4/11.
//  Copyright © 2019 Wayne. All rights reserved.
//

import Foundation

struct SeatPlan: Decodable {
	let result: Int
	let data: Data
	
	enum CodingKeys: String, CodingKey {
		case result = "Result"
		case data = "Data"
	}
    
    var areas: [SeatLayoutData.Area] {
        return data.seatLayoutData.areas
    }
    
}

extension SeatPlan {
	
	struct Data: Decodable {
		let seatLayoutData: SeatLayoutData
		
		enum CodingKeys: String, CodingKey {
			case seatLayoutData = "SeatLayoutData"
		}
	}
}

struct SeatLayoutData: Decodable {
	let areas: [Area]
	
	enum CodingKeys: String, CodingKey {
		case areas = "Areas"
	}
}

extension SeatLayoutData {
	
	struct Area: Decodable {
		let rows: [Row]
		
		enum CodingKeys: String, CodingKey {
			case rows = "Rows"
		}
	}
}

extension SeatLayoutData.Area {
	
	struct Row: Decodable {
		let physicalName: String?
		let seats: [Seat]
		
		enum CodingKeys: String, CodingKey {
			case physicalName = "PhysicalName"
			case seats = "Seats"
		}
	}
}

extension SeatLayoutData.Area.Row {
	
	class Seat: Decodable {
		let id: String
		let originalStatus: Int
		let position: Position
		let status: Int
        var score: Int
		
		enum CodingKeys: String, CodingKey {
			case id = "Id"
			case originalStatus = "OriginalStatus"
			case position = "Position"
			case status = "Status"
		}
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decode(String.self, forKey: .id)
            self.originalStatus = try container.decode(Int.self, forKey: .originalStatus)
            self.position = try container.decode(Position.self, forKey: .position)
            self.status = try container.decode(Int.self, forKey: .status)
            self.score = 0
        }
        
        var seatStatus: Status {
            return Status(rawValue: status)
        }
	}
}

extension SeatLayoutData.Area.Row.Seat {
    
    enum Status: Int {
        case empty = 0
        case sold = 2
        case other
        
        init(rawValue: Int) {
            if rawValue == 0 {
                self = .empty
            } else if rawValue == 2 {
                self = .sold
            } else {
                self = .other
            }
        }
    }
	
	struct Position: Decodable {
		let areaNumber: Int
		let columnIndex: Int
		let rowIndex: Int
		
		enum CodingKeys: String, CodingKey {
			case areaNumber = "AreaNumber"
			case columnIndex = "ColumnIndex"
			case rowIndex = "RowIndex"
		}
	}
}
