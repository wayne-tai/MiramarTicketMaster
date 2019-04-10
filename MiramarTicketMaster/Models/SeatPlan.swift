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
		let physicalName: String
		let seats: [Seat]
		
		enum CodingKeys: String, CodingKey {
			case physicalName = "PhysicalName"
			case seats = "Seats"
		}
	}
}

extension SeatLayoutData.Area.Row {
	
	struct Seat: Decodable {
		let id: String
		let originalStatus: Int
		let position: Position
		let status: Int
		
		enum CodingKeys: String, CodingKey {
			case id = "Id"
			case originalStatus = "OriginalStatus"
			case position = "Position"
			case status = "Status"
		}
	}
}

extension SeatLayoutData.Area.Row.Seat {
	
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
