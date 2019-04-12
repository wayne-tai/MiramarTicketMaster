//
//  OrderViewModel.swift
//  MiramarTicketMaster
//
//  Created by 𝕎𝔸𝕐ℕ𝔼 on 2019/4/11.
//  Copyright © 2019 Wayne. All rights reserved.
//

import Foundation

protocol OrderViewModelDelegate: AnyObject {
	func didOrderTicketAndPaymentSuccess()
}

class OrderViewModel: ViewModel {
	
	weak var logger: ViewModelLogger?
	
	weak var delegate: OrderViewModelDelegate?
	
	var sessionId: String
	let authToken: String
	let member: Member
	let order: Order
	
	let network = MiramarService()
	
	let repeatInterval: DispatchTimeInterval = .seconds(2)
	var timer: DispatchSourceTimer?
	let timerQueue: DispatchQueue = DispatchQueue(label: "idv.wayne.miramar.ticket.master.order.timer", attributes: .concurrent)
	
	init(token: String, member: Member, order: Order, sessionId: String = Config().sessionId) {
		self.authToken = token
		self.member = member
		self.sessionId = sessionId
		self.order = order
	}
	
	func start() {
		timer?.cancel()
		
		timer = DispatchSource.makeTimerSource(queue: timerQueue)
		timer?.schedule(deadline: .now(), repeating: repeatInterval, leeway: .milliseconds(1))
		
		timer?.setEventHandler { [weak self] in
			guard let self = self else { return }
			self.orderTicket()
		}
		
		timer?.resume()
	}
	
	private func startOrderTicket() {
		timer?.cancel()
		
		timer = DispatchSource.makeTimerSource(queue: timerQueue)
		timer?.schedule(deadline: .now(), repeating: repeatInterval, leeway: .milliseconds(1))
		
		timer?.setEventHandler { [weak self] in
			guard let self = self else { return }
			self.orderTicket()
		}
		
		timer?.resume()
	}
	
	private func startOrderPayment() {
		timer?.cancel()
		
		timer = DispatchSource.makeTimerSource(queue: timerQueue)
		timer?.schedule(deadline: .now(), repeating: repeatInterval, leeway: .milliseconds(1))
		
		timer?.setEventHandler { [weak self] in
			guard let self = self else { return }
			self.orderPayment()
		}
		
		timer?.resume()
	}
	
	private func stop() {
		timer?.cancel()
		timer = nil
	}
	
	func orderTicket() {
		logger?.log("[INFO] Preparing to order a ticker...\n")
		_ = network.orderTicker(with: authToken, order: order)
			.subscribe { [weak self] (event) in
				guard let self = self else { return }
				switch event {
				case .success(let orderTicket):
					guard orderTicket.result == 1 else { return } 
					self.logger?.log("[SUCCESS] Order ticket success!\n")
					self.logger?.log("============================\n\n")
					self.stop()
					self.sessionId = orderTicket.data.order.userSessionId
					self.startOrderPayment()
					
				case .error(let error):
					self.logger?.log("[FAILED] Order ticket failed...\n\n")
					self.logger?.log("[ERROR] \(error)\n")
				}
		}
	}
	
	func orderPayment() {
		logger?.log("[INFO] Preparing to order payment...\n")
		let quantity = Int(order.ticketTypes.first!.qty)!
		let value = Int(order.ticketTypes.first!.priceInCents)!
		let paymentValue = quantity * value
		
		let payment = Payment()
		payment.sessionId = sessionId
		payment.paymentValueCents = String(paymentValue)
		payment.optionalMemberId = member.memberId
		payment.customerEmail = member.email
		payment.customerPhone = member.mobilePhone
		payment.customerName = member.fullName
		
		_ = network.orderPayment(with: authToken, payment: payment)
			.subscribe { [weak self] (event) in
				guard let self = self else { return }
				switch event {
				case .success(let orderPayment):
					guard orderPayment.result == 1 else { return }
					self.logger?.log("[SUCCESS] Order payment success!\n")
					self.logger?.log("============================\n\n")
					self.stop()
					self.delegate?.didOrderTicketAndPaymentSuccess()
					
				case .error(let error):
					self.logger?.log("[FAILED] Order payment failed...\n\n")
					self.logger?.log("[ERROR] \(error)\n")
				}
		}
	}
}
