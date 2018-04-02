//
//  ShowTime.swift
//  MiramarTicketMaster
//
//  Created by Wayne on 2018/3/27.
//  Copyright © 2018年 Wayne. All rights reserved.
//

import Foundation

struct Cinema: CBDecodableModel {
    let movieList: [Movie]
    let cinemaId: String
    let cinemaCName: String
    let cinemaEName: String
    
    enum ObjectKeys: String, CodingKey {
        case cinemaList = "CinemaList"
    }
    
    enum CodingKeys: String, CodingKey {
        case movieList = "MovieList"
        case cinemaId = "CinemaId"
        case cinemaCName = "CinemaCName"
        case cinemaEName = "CinemaEName"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        movieList = try container.decode([Movie].self, forKey: .movieList)
        cinemaId = try container.decode(String.self, forKey: .cinemaId)
        cinemaCName = try container.decode(String.self, forKey: .cinemaCName)
        cinemaEName = try container.decode(String.self, forKey: .cinemaEName)
    }
    
    internal static func cinemas(from data: Data) throws -> [Cinema] {
        return try CBDecodableModels<Cinema>.decodeInResultObject(from: data, objectKey: ObjectKeys.cinemaList.stringValue).models
    }
}

struct Movie: Decodable {
    let showDateList: [ShowDate]
    let movieCName: String
    let movieEName: String
    let rate: String
    let filmArray: String
    
    enum CodingKeys: String, CodingKey {
        case showDateList = "ShowDateList"
        case movieCName = "MovieCName"
        case movieEName = "MovieEName"
        case rate = "Rate"
        case filmArray = "FilmArray"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        showDateList = try container.decode([ShowDate].self, forKey: .showDateList)
        movieCName = try container.decode(String.self, forKey: .movieCName)
        movieEName = try container.decode(String.self, forKey: .movieEName)
        rate = try container.decode(String.self, forKey: .rate)
        filmArray = try container.decode(String.self, forKey: .filmArray)
    }
}

struct ShowDate: Decodable {
    let showTimeList: [ShowTime]
    let showDateISO: String
    let showDateCht: String
    let showDateEn: String
    
    enum CodingKeys: String, CodingKey {
        case showTimeList = "ShowTimeList"
        case showDateISO = "ShowDateISO"
        case showDateCht = "ShowDateCht"
        case showDateEn = "ShowDateEn"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        showTimeList = try container.decode([ShowTime].self, forKey: .showTimeList)
        showDateISO = try container.decode(String.self, forKey: .showDateISO)
        showDateCht = try container.decode(String.self, forKey: .showDateCht)
        showDateEn = try container.decode(String.self, forKey: .showDateEn)
    }
    
    internal var showDate: Date? {
        return Date(fromDateString: showDateISO)
    }
}

struct ShowTime: Decodable {
    let sessionList: [Session]
    let movieHallCht: String
    let movieHallEn: String
    
    enum CodingKeys: String, CodingKey {
        case sessionList = "SessionList"
        case movieHallCht = "MovieHallCht"
        case movieHallEn = "MovieHallEn"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sessionList = try container.decode([Session].self, forKey: .sessionList)
        movieHallCht = try container.decode(String.self, forKey: .movieHallCht)
        movieHallEn = try container.decode(String.self, forKey: .movieHallEn)
    }
}

struct Session: Decodable {
    let sessionId: String
    let availableSeats: String
    let showTime: String
    let status: Int
    let movieHallCode: String
    
    enum CodingKeys: String, CodingKey {
        case sessionId = "SessionId"
        case availableSeats = "AvailableSeats"
        case showTime = "ShowTime"
        case status = "Status"
        case movieHallCode = "MovieHallCode"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sessionId = try container.decode(String.self, forKey: .sessionId)
        availableSeats = try container.decode(String.self, forKey: .availableSeats)
        showTime = try container.decode(String.self, forKey: .showTime)
        status = try container.decode(Int.self, forKey: .status)
        movieHallCode = try container.decode(String.self, forKey: .movieHallCode)
    }
}
