//
//  LoginViewModel.swift
//  MiramarTicketMaster
//
//  Created by 𝕎𝔸𝕐ℕ𝔼 on 2019/4/10.
//  Copyright © 2019 Wayne. All rights reserved.
//

import Foundation

protocol LoginViewModelDelegate: AnyObject {
	func isGoingToGetAuthToken()
	func didAuthTokenGetSucceed(token: String)
	func isGoingToLogin()
	func didLoginCompleted(with token: String, member: Member)
}

class LoginViewModel: ViewModel {
	
	weak var logger: ViewModelLogger?
	
	weak var delegate: LoginViewModelDelegate?
	
	let sessionId: String
	
	var authToken: String = ""
	
	let network = MiramarService()
	
	init(sessionId: String = Config().sessionId) {
		self.sessionId = sessionId
	}
	
	func start() {
		if authToken.isEmpty {
			getAuthToken()
		} else {
			login(with: authToken)
		}
	}
	
	func getAuthToken() {
		log.info("[INFO] Get auth token...")
		_ = network.getAuthToken()
			.subscribe { [weak self] (event) in
				guard let self = self else { return }
				switch event {
				case .success(let authToken):
					guard authToken.result == 1 else { return }
					log.info("[SUCCESS] Get auth token success!")
					log.info("============================")
					self.authToken = authToken.token
					self.login(with: authToken.token)
					self.delegate?.didAuthTokenGetSucceed(token: authToken.token)
					
				case .error(let error):
					log.info("[FAILED] Get auth token failed...")
					log.info("[ERROR] \(error.localizedDescription)")
                    self.getAuthToken()
				}
		}
	}
	
	func login(with token: String) {
		log.info("[INFO] Trying to login...")
		_ = network.login(with: token, sessionId: sessionId)
			.subscribe { [weak self] (event) in
				guard let self = self else { return }
				switch event {
				case .success(let member):
					guard member.result == 1 else { return }
					log.info("[SUCCESS] Login success!")
					log.info("============================")
					self.delegate?.didLoginCompleted(with: self.authToken, member: member)
					
				case .error(let error):
					log.info("[FAILED] Get member info failed...")
					log.info("[ERROR] \(error.localizedDescription)")
                    self.login(with: token)
				}
			}
	}
}
