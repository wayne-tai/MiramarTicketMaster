//
//  SeatViewModel.swift
//  MiramarTicketMaster
//
//  Created by Wayne on 2019/4/11.
//  Copyright © 2019 Wayne. All rights reserved.
//

import Foundation

protocol SeatViewModelDelegate: AnyObject {
    func didGetSeatPlan(seatPlan: SeatPlan)
}

class SeatViewModel: ViewModel {
    
    weak var logger: ViewModelLogger?
    
    weak var delegate: SeatViewModelDelegate?
    
    let movieSessionId: String
    let authToken: String
    
    let network = MiramarService()
    
    let repeatInterval: DispatchTimeInterval = .seconds(2)
    var timer: DispatchSourceTimer?
    let timerQueue: DispatchQueue = DispatchQueue(label: "idv.wayne.miramar.ticket.master.seat.timer", attributes: .concurrent)
    
    init(token: String, movieSessionId: String) {
        self.authToken = token
        self.movieSessionId = movieSessionId
    }
    
    func start() {
        timer?.cancel()
        
        timer = DispatchSource.makeTimerSource(queue: timerQueue)
        timer?.schedule(deadline: .now(), repeating: repeatInterval, leeway: .milliseconds(1))
        
        timer?.setEventHandler { [weak self] in
            guard let self = self else { return }
            self.getSeatPlan()
        }
        
        timer?.resume()
    }
    
    func getSeatPlan() {
        logger?.log("Get seat plan...\n")
        _ = network.getSeatPlan(with: authToken, movieSessionId: movieSessionId)
            .subscribe { [weak self] (event) in
                guard let self = self else { return }
                switch event {
                case .success(let seatPlan):
                    self.logger?.log("Get seat plan success!\n")
                    self.logger?.log("============================\n\n")
                    self.timer?.cancel()
                    self.timer = nil
                    self.delegate?.didGetSeatPlan(seatPlan: seatPlan)
                    
                case .error(let error):
                    self.logger?.log("Get seat plan failed...\n\n")
                    self.logger?.log("Error \(error)\n")
                }
        }
    }
}