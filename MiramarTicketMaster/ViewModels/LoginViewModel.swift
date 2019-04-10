//
//  LoginViewModel.swift
//  MiramarTicketMaster
//
//  Created by 𝕎𝔸𝕐ℕ𝔼 on 2019/4/10.
//  Copyright © 2019 Wayne. All rights reserved.
//

import Foundation

protocol LoginViewModelDelegate: AnyObject {
	func didLoginCompleted(with token: String, authData: String)
}

class LoginViewModel: ViewModel {
	
	weak var logger: ViewModelLogger?
	
	weak var delegate: LoginViewModelDelegate?
	
	let sessionId: String
	
	var authToken: String = ""
	
	let network = MiramarService()
	
	init(sessionId: String) {
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
		logger?.log("Get auth token...\n")
		_ = network.getAuthToken()
			.subscribe { [weak self] (event) in
				guard let self = self else { return }
				switch event {
				case .success(let authToken):
					self.logger?.log("Get auth token success!\n")
					self.logger?.log("============================\n\n")
					self.authToken = authToken.token
					self.login(with: authToken.token)
					
				case .error(let error):
					self.logger?.log("Get auth token failed...\n\n")
					self.logger?.log("Error \(error)\n")
				}
		}
	}
	
	func login(with token: String) {
		logger?.log("Trying to login...\n")
		_ = network.login(with: token, sessionId: sessionId)
			.subscribe { [weak self] (event) in
				guard let self = self else { return }
				switch event {
				case .success(let member):
					self.logger?.log("Login success!\n")
					self.logger?.log("============================\n\n")
					self.delegate?.didLoginCompleted(with: self.authToken, authData: member.info.authData)
					
				case .error(let error):
					self.logger?.log("Get member info failed...\n\n")
					self.logger?.log("Error \(error)\n")
				}
			}
	}
}
