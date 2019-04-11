//
//  MovieSession.swift
//  MiramarTicketMaster
//
//  Created by 𝕎𝔸𝕐ℕ𝔼 on 2019/4/11.
//  Copyright © 2019 Wayne. All rights reserved.
//

import Foundation

class MovieSession: Decodable {
	let result: Int
	let data: ShowDates
	
	enum CodingKeys: String, CodingKey {
		case result = "Result"
		case data = "Data"
	}
}

extension MovieSession {
	
	class ShowDates: Decodable {
		var showDates: [ShowDate]
		
		enum CodingKeys: String, CodingKey {
			case showDates = "ShowDates"
		}
	}
	
	class ShowDate: Decodable {
		let movies: [Movie]
		let dateTime: String
		let week: String
		
		enum CodingKeys: String, CodingKey {
			case movies = "Movies"
			case dateTime = "DateTime"
			case week = "Week"
		}
	}
}

extension MovieSession.ShowDate {
	
	class Movie: Decodable {
		let title: String
		let titleAlt: String
		let screens: [Screen]
		
		enum CodingKeys: String, CodingKey {
			case title = "Title"
			case titleAlt = "TitleAlt"
			case screens = "Screens"
		}
	}
}

extension MovieSession.ShowDate.Movie {
	
	class Screen: Decodable {
		var sessions: [Session]
		let screenName: String
		
		enum CodingKeys: String, CodingKey {
			case sessions = "Sessions"
			case screenName = "ScreenName"
		}
	}
}

extension MovieSession.ShowDate.Movie.Screen {
	
	class Session: Decodable {
		let sessionId: String
		let showtime: String
		
		enum CodingKeys: String, CodingKey {
			case sessionId = "SessionId"
			case showtime = "Showtime"
		}
	}
}
