//
//  SeatAndTicketViewModel.swift
//  MiramarTicketMaster
//
//  Created by Wayne on 2019/4/11.
//  Copyright © 2019 Wayne. All rights reserved.
//

import Foundation

protocol SeatAndTicketViewModelDelegate: AnyObject {
	func willGetSeatPlan()
	func didGetSeats()
	
	func willGetTicketType()
	func didGetTicketTypes()
	
	func didTasksCompleted(seats: [Order.SelectedSeat], ticketTypes: [Order.TicketType], sessionId: String)
	func didTaskFailed()
}

class SeatAndTicketViewModel: ViewModel {
    
    weak var logger: ViewModelLogger?
    
    weak var delegate: SeatAndTicketViewModelDelegate?
    
    var seatViewModel: SeatViewModel?
    var ticketViewModel: TicketTypesViewModel?
    
    var targetMovieDateTimes: [Date] = []
    var targetMovieName: String = ""
    var targetSeats: [TargetSeatRange] = []
    var targetTicketQuantity: Int = 0
    var targetTicketType: String = ""
    var screenFilter: ScreenFilter
	
    var movieSession: MovieSession
    let authToken: String
    let memberId: String
	
	var selectedSession: MovieSession.ShowDate.Movie.Screen.Session?
	var selectedSeats: [Order.SelectedSeat] = []
    var ticketTypes: [Order.TicketType] = []
    
    let network = MiramarService()
    
    let repeatInterval: DispatchTimeInterval = .seconds(2)
    var timer: DispatchSourceTimer?
    let timerQueue: DispatchQueue = DispatchQueue(label: "idv.wayne.miramar.ticket.master.seat.and.ticket.timer", attributes: .concurrent)
    
	init(token: String, memberId: String, movieSession: MovieSession) {
        self.authToken = token
        self.memberId = memberId
        self.movieSession = movieSession
		
		let config = Config()
		self.targetMovieDateTimes = config.targetMovieDateTimes
		self.targetMovieName = config.targetMovieName
		self.targetSeats = config.targetSeats
		self.targetTicketQuantity = config.targetTicketQuantity
        self.targetTicketType = config.targetTicketType
        self.screenFilter = config.screenFilter
    }
    
    func start() {
        log.info("[INFO] Trying to get the best movie session...")
        var optionalSession: MovieSession.ShowDate.Movie.Screen.Session?
        while optionalSession == nil {
            guard let targetDate = targetMovieDateTimes.first else {
				delegate?.didTaskFailed()
				log.info("[FAILED] No more movie sessions in target dates could be selected")
				return
			}
			
            let finder = MovieSessionFinder(targetMovieName: targetMovieName, screenFilter: screenFilter, tolerance: 14400.0)
            optionalSession = finder.session(from: &self.movieSession, forTargetDate: targetDate)
            
            if let session = optionalSession {
                log.info("[SUCCESS] Get the best movie session \(session.sessionId), at time \(session.showtime)")
                log.info("============================")
				selectedSession = session
                break
            } else {
                targetMovieDateTimes = Array(targetMovieDateTimes.dropFirst())
            }
        }
        
        guard let session = optionalSession else {
			delegate?.didTaskFailed()
            log.info("[FAILED] No movie session could be choose")
            return
        }
        
        if selectedSeats.isEmpty {
            seatViewModel = SeatViewModel(token: authToken, movieSessionId: session.sessionId)
            seatViewModel?.delegate = self
            seatViewModel?.start()
        }
        
        if ticketTypes.isEmpty {
            ticketViewModel = TicketTypesViewModel(token: authToken, memberId: memberId, movieSessionId: session.sessionId)
            ticketViewModel?.delegate = self
            ticketViewModel?.start()
        }
    }
	
	func complete() {
		guard !selectedSeats.isEmpty else { return }
		guard !ticketTypes.isEmpty else { return }
		
		delegate?.didTasksCompleted(
			seats: selectedSeats,
			ticketTypes: ticketTypes,
			sessionId: selectedSession!.sessionId)
	}
    
}

extension SeatAndTicketViewModel: SeatViewModelDelegate {
	func willGetSeatPlan() {
		delegate?.willGetSeatPlan()
	}
	
    func didGetSeatPlan(seatPlan: SeatPlan, movieSessionId: String) {
        log.info("[INFO] Trying to get the best seats...")
        let finder = SeatFinder(targetSeats: targetSeats, targetTicketQuantity: targetTicketQuantity)
        let seats = finder.seats(from: seatPlan)
        
        if !seats.isEmpty, let areaCategoryCode = seatPlan.areas.first?.areaCategoryCode {
            log.info("[SUCCESS] Get the best seats \(seats.map { $0.id })")
            log.info("============================")
			selectedSeats = seats.map { $0.toSelectedSeat(with: areaCategoryCode) }
			delegate?.didGetSeats()
			complete()
        } else {
            log.info("[INFO] No seats could be found in current movie session...")
            log.info("[INFO] Fallback to get another movie session...")
            selectedSeats = []
            start()
        }
    }
}

extension SeatAndTicketViewModel: TicketTypesViewModelDelegate {
	func willGetTicketType() {
		delegate?.willGetTicketType()
	}
    
    func didGetTicketType(ticketType: TicketType) {
		log.info("[INFO] Trying to find out the ticket type...")
        let finder = TicketFinder(targetTicketQuantity: targetTicketQuantity, targetTicketType: targetTicketType)
		guard let ticket = finder.ticket(from: ticketType) else {
			log.info("[FAILED] Could not find out any availiale ticket type")
			delegate?.didTaskFailed()
			return
		}
		
		log.info("[SUCCESS] Get the ticket type")
		ticketTypes = [ticket.toOrderTicketType(with: targetTicketQuantity)]
		delegate?.didGetTicketTypes()
		complete()
    }
}
