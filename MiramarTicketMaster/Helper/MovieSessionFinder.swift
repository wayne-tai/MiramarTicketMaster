//
//  MovieSessionFinder.swift
//  MiramarTicketMaster
//
//  Created by Wayne on 2019/4/11.
//  Copyright © 2019 Wayne. All rights reserved.
//

import Foundation

class MovieSessionFinder {
    
    let tolerance: Double
    let targetMovieName: String
    let screenFilter: ScreenFilter
    
    init(targetMovieName: String, screenFilter: ScreenFilter, tolerance: Double) {
        self.targetMovieName = targetMovieName
        self.tolerance = tolerance
        self.screenFilter = screenFilter
    }
    
    func session(
        from movieSession: inout MovieSession,
        forTargetDate targetDate: Date) -> MovieSession.ShowDate.Movie.Screen.Session?
    {
        guard let targetShowDateIndex = movieSession.data.showDates.firstIndex(where: { (showDate) -> Bool in
            guard let date = showDate.dateTime.date else { return false }
            return Calendar.current.isDate(date, inSameDayAs: targetDate)
        }) else { return nil }
        
        guard let targetMovie = movieSession.data.showDates[targetShowDateIndex].movies.first(where: { (movie) -> Bool in
            movie.titleAlt.contains(self.targetMovieName)
        }) else { return nil }
        
        guard let targetScreen = targetMovie.screens.first(where: { (screen) -> Bool in
            screenFilter.validate(with: screen.screenName)
        }) else { return nil }
        
        let timeOffsets = targetScreen.sessions.map { (session) -> Double? in
            guard let date = session.showtime.date else { return nil }
            return abs(targetDate.timeIntervalSince(date))
        }
        
        guard !timeOffsets.isEmpty else { return nil }
        var targetIndex: Int = -1
//        var smallestTimeOffset: Double = 14400.0
        var smallestTimeOffset: Double = tolerance
        for (idx, offset) in timeOffsets.enumerated() {
            guard let offset = offset else { continue }
            guard offset < smallestTimeOffset else { continue }
            targetIndex = idx
            smallestTimeOffset = offset
        }
        
        guard targetIndex > 0 else { return nil }
        return targetScreen.sessions.remove(at: targetIndex)
    }
}
