//
//  TicketTypesViewModel.swift
//  MiramarTicketMaster
//
//  Created by Wayne on 2019/4/11.
//  Copyright © 2019 Wayne. All rights reserved.
//

import Foundation
import RxSwift

protocol TicketTypesViewModelDelegate: AnyObject {
    func didGetTicketType(ticketType: TicketType)
}

class TicketTypesViewModel: ViewModel {
    
    weak var logger: ViewModelLogger?
    
    weak var delegate: TicketTypesViewModelDelegate?
    
    let movieSessionId: String
    let authToken: String
    let memberId: String
    
    let network = MiramarService()
    
    let repeatInterval: DispatchTimeInterval = .seconds(2)
    var timer: DispatchSourceTimer?
    let timerQueue: DispatchQueue = DispatchQueue(label: "idv.wayne.miramar.ticket.master.ticket.timer", attributes: .concurrent)
    
    init(token: String, memberId: String, movieSessionId: String) {
        self.authToken = token
        self.memberId = memberId
        self.movieSessionId = movieSessionId
    }
    
    func start() {
        timer?.cancel()
        
        timer = DispatchSource.makeTimerSource(queue: timerQueue)
        timer?.schedule(deadline: .now(), repeating: repeatInterval, leeway: .milliseconds(1))
        
        timer?.setEventHandler { [weak self] in
            guard let self = self else { return }
            self.getTicketTypes()
        }
        
        timer?.resume()
    }
    
    func getTicketTypes() {
        logger?.log("[INFO] Get ticket types...\n")
        _ = network.getTicketTypes(with: authToken, memberId: memberId, movieSessionId: movieSessionId)
            .subscribe { [weak self] (event) in
                guard let self = self else { return }
                switch event {
                case .success(let ticketTypes):
					guard ticketTypes.result == 1 else { return }
                    self.logger?.log("[SUCCESS] Get ticket types success!\n")
                    self.logger?.log("============================\n\n")
                    self.timer?.cancel()
                    self.timer = nil
                    self.delegate?.didGetTicketType(ticketType: ticketTypes)
                    
                case .error(let error):
                    self.logger?.log("[FAILED] Get ticket types failed...\n\n")
                    self.logger?.log("[ERROR] \(error)\n")
                }
        }
    }
}
