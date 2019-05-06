//
//  MovieViewModel.swift
//  MiramarTicketMaster
//
//  Created by 𝕎𝔸𝕐ℕ𝔼 on 2019/4/11.
//  Copyright © 2019 Wayne. All rights reserved.
//

import Foundation

protocol MovieViewModelDelegate: AnyObject {
	func isGoingToGetMovieSession()
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
		log.info("[INFO] Get movie sessions...\n")
		delegate?.isGoingToGetMovieSession()
		_ = network.getMovieSessions(with: authToken)
			.subscribe { [weak self] (event) in
				guard let self = self else { return }
				switch event {
				case .success(let movieSession):
					guard movieSession.result == 1 else { return }
					log.info("[SUCCESS] Get movie session success!\n")
					log.info("============================\n\n")
					self.timer?.cancel()
					self.timer = nil
					self.delegate?.didGetMovieSession(movieSession: movieSession)
					
				case .error(let error):
					log.info("[FAILED] Get movie session failed...\n")
					log.info("[ERROR] \(error.localizedDescription)\n")
				}
		}
	}
}
