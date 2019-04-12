//
//  MovieViewModel.swift
//  MiramarTicketMaster
//
//  Created by 𝕎𝔸𝕐ℕ𝔼 on 2019/4/11.
//  Copyright © 2019 Wayne. All rights reserved.
//

import Foundation

protocol MovieViewModelDelegate: AnyObject {
    func didGetMovieSession(movieSession: MovieSession)
}

class MovieViewModel: ViewModel {
	
	weak var logger: ViewModelLogger?
	
	weak var delegate: MovieViewModelDelegate?
	
	let sessionId: String
	let authToken: String
	
	let network = MiramarService()
	
	let repeatInterval: DispatchTimeInterval = .seconds(2)
	var timer: DispatchSourceTimer?
	let timerQueue: DispatchQueue = DispatchQueue(label: "idv.wayne.miramar.ticket.master.movie.timer", attributes: .concurrent)
	
	init(token: String, sessionId: String = Config().sessionId) {
		self.authToken = token
		self.sessionId = sessionId
	}
	
	func start() {
		timer?.cancel()
		
		timer = DispatchSource.makeTimerSource(queue: timerQueue)
		timer?.schedule(deadline: .now(), repeating: repeatInterval, leeway: .milliseconds(1))
		
		timer?.setEventHandler { [weak self] in
			guard let self = self else { return }
			self.getMovieSessions()
		}
		
		timer?.resume()
	}
	
	func getMovieSessions() {
		logger?.log("[INFO] Get movie sessions...\n")
		_ = network.getMovieSessions(with: authToken)
			.subscribe { [weak self] (event) in
				guard let self = self else { return }
				switch event {
				case .success(let movieSession):
					guard movieSession.result == 1 else { return }
					self.logger?.log("[SUCCESS] Get movie session success!\n")
					self.logger?.log("============================\n\n")
					self.timer?.cancel()
					self.timer = nil
					self.delegate?.didGetMovieSession(movieSession: movieSession)
					
				case .error(let error):
					self.logger?.log("[FAILED] Get movie session failed...\n")
					self.logger?.log("[ERROR] \(error.localizedDescription)\n")
				}
		}
	}
}
