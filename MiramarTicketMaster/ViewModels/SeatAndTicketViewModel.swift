//
//  SeatAndTicketViewModel.swift
//  MiramarTicketMaster
//
//  Created by Wayne on 2019/4/11.
//  Copyright © 2019 Wayne. All rights reserved.
//

import Foundation

class SeatAndTicketViewModel: ViewModel {
    
    weak var logger: ViewModelLogger?
    
    weak var delegate: SeatViewModelDelegate?
    
    var seatViewModel: SeatViewModel?
    var ticketViewModel: TicketTypesViewModel?
    
    var targetMovieDateTimes: [Date] = []
    var targetMovieName: String = ""
    var targetSeats: [TargetSeatRange] = []
    var targetTicketQuantity: Int = 0
    
    var movieSession: MovieSession
    let authToken: String
    let memberId: String
    
    var seatPlan: SeatPlan?
    var ticketType: TicketType?
    
    let network = MiramarService()
    
    let repeatInterval: DispatchTimeInterval = .seconds(2)
    var timer: DispatchSourceTimer?
    let timerQueue: DispatchQueue = DispatchQueue(label: "idv.wayne.miramar.ticket.master.seat.and.ticket.timer", attributes: .concurrent)
    
    init(token: String, memberId: String, movieSession: MovieSession) {
        self.authToken = token
        self.memberId = memberId
        self.movieSession = movieSession
    }
    
    func start() {
        logger?.log("Trying to get the best movie session...\n")
        var optionalSession: MovieSession.ShowDate.Movie.Screen.Session?
        while optionalSession == nil {
            guard let targetDate = targetMovieDateTimes.first else { return }
            let finder = MovieSessionFinder(targetMovieName: targetMovieName, tolerance: 14400.0)
            optionalSession = finder.session(from: &self.movieSession, forTargetDate: targetDate)
            
            if let session = optionalSession {
                logger?.log("Get the best movie session \(session.sessionId), at time \(session.showtime)\n")
                logger?.log("============================\n\n")
                break
            } else {
                targetMovieDateTimes = Array(targetMovieDateTimes.dropFirst())
            }
        }
        
        guard let session = optionalSession else {
            logger?.log("No movie session could be choose\n")
            return
        }
        
        if seatPlan == nil {
            seatViewModel = SeatViewModel(token: authToken, movieSessionId: session.sessionId)
            seatViewModel?.delegate = self
            seatViewModel?.logger = self.logger
            seatViewModel?.start()
        }
        
        if ticketType == nil {
            ticketViewModel = TicketTypesViewModel(token: authToken, memberId: memberId, movieSessionId: session.sessionId)
            ticketViewModel?.delegate = self
            ticketViewModel?.logger = self.logger
            ticketViewModel?.start()
        }
    }
    
}

extension SeatAndTicketViewModel: SeatViewModelDelegate {
    func didGetSeatPlan(seatPlan: SeatPlan, movieSessionId: String) {
        self.seatPlan = seatPlan
        
        logger?.log("Trying to get the best seats...\n")
        let finder = SeatFinder(targetSeats: targetSeats, targetTicketQuantity: targetTicketQuantity)
        let seats = finder.seats(from: seatPlan)
        
        if !seats.isEmpty {
            logger?.log("Get the best seats \(seats.map { $0.id })\n")
            logger?.log("============================\n\n")
            
        } else {
            logger?.log("No seats could be found in current movie session...")
            self.seatPlan = nil
            start()
        }
    }
}

extension SeatAndTicketViewModel: TicketTypesViewModelDelegate {
    
    func didGetTicketType(ticketType: TicketType) {
        self.ticketType = ticketType
    }
}
