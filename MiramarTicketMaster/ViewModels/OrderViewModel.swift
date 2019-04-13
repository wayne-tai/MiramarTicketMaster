//
//  OrderViewModel.swift
//  MiramarTicketMaster
//
//  Created by 𝕎𝔸𝕐ℕ𝔼 on 2019/4/11.
//  Copyright © 2019 Wayne. All rights reserved.
//

import Foundation

protocol OrderViewModelDelegate: AnyObject {
	func willOrderTicket()
	func didTicketOrdered()
	
	func willGetOrderPayment()
	func didGetOrderPayment()
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
		log.info("[INFO] Preparing to order a ticker...")
		delegate?.willOrderTicket()
		
		_ = network.orderTicker(with: authToken, order: order)
			.subscribe { [weak self] (event) in
				guard let self = self else { return }
				switch event {
				case .success(let orderTicket):
					guard orderTicket.result == 1 else { return } 
					log.info("[SUCCESS] Order ticket success!")
					log.info("============================")
					self.stop()
					self.sessionId = orderTicket.data.order.userSessionId
					
					self.delegate?.didTicketOrdered()
					self.startOrderPayment()
					
				case .error(let error):
					log.info("[FAILED] Order ticket failed...")
					log.info("[ERROR] \(error.localizedDescription)")
				}
		}
	}
	
	func orderPayment() {
		log.info("[INFO] Preparing to order payment...")
		delegate?.willGetOrderPayment()
		
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
					log.info("[SUCCESS] Order payment success!")
					log.info("============================")
					self.stop()
					self.delegate?.didGetOrderPayment()
					
				case .error(let error):
					log.info("[FAILED] Order payment failed...")
					log.info("[ERROR] \(error.localizedDescription)")
				}
		}
	}
}
