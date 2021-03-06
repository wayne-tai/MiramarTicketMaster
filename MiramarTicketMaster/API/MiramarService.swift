//
//  MiramarService.swift
//  MiramarTicketMaster
//
//  Created by 𝕎𝔸𝕐ℕ𝔼 on 2019/4/10.
//  Copyright © 2019 Wayne. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

class MiramarService: NetworkService {
	
	func getAuthToken() -> Single<AuthToken> {
		let path = APIModule.console + "/AuthToken/Post"
		return request(.post, urlString: path)
			.map { try $0.decode() }
	}
	
	func login(with token: String, sessionId: String) -> Single<Member> {
		let path = APIModule.console + "/ValidateMember/Post"
		let headers: HTTPHeaders = [
			"Authorization": "MAuth \(token)"
		]
		let params: Parameters = [
			"MemberPassword": "wayneJr0513",
			"PushToken": "f3OK74bceos:APA91bEZFYlbns0x0MeyVwT-8XJRkVP4N42b8omfTsT2tR0ieeXov1EJXoCTTL4y9iLAoVnea2aQn7bx11TxNAxvKP4iLCfpWgKQJWq8JYTFsUyoUgFIylKxX9tS6FQejvaSLYikuYrW",
			"MemberLogin": "wudypig@gmail.com",
			"UserSessionId": "\(sessionId)",
			"Platform":"2"
		]
		return request(.post, urlString: path, parameters: params, encoding: .json, headers: headers)
			.map { try $0.decode() }
	}
	
	func getMovieSessions(with token: String) -> Single<MovieSession> {
		let path = APIModule.console + "/MovieSession/Post"
		let headers: HTTPHeaders = [
			"Authorization": "MAuth \(token)"
		]
		return request(.post, urlString: path, headers: headers)
			.map { try $0.decode() }
	}
	
	func getSeatPlan(with token: String, movieSessionId: String) -> Single<SeatPlan> {
		let path = APIModule.console + "/SeatPlan/Post"
		let headers: HTTPHeaders = [
			"Authorization": "MAuth \(token)"
		]
		let params: Parameters = [
			"CinemaId": "1001",
			"SessionId": movieSessionId
		]
		return request(.post, urlString: path, parameters: params, headers: headers)
			.map { try $0.decode() }
	}
    
    func getTicketTypes(with token: String, memberId: String, movieSessionId: String) -> Single<TicketType> {
        let path = APIModule.console + "/TicketType/Post"
        let headers: HTTPHeaders = [
            "Authorization": "MAuth \(token)"
        ]
        let params: Parameters = [
            "CinemaId": "1001",
            "MemberId": memberId,
            "SessionId": movieSessionId
        ]
        return request(.post, urlString: path, parameters: params, headers: headers)
            .map { try $0.decode() }
    }
	
	func orderTicker(with token: String, order: Order) -> Single<OrderTicket> {
		let path = APIModule.console + "/OrderTicket/Post"
		let headers: HTTPHeaders = [
			"Authorization": "MAuth \(token)"
		]
		let params = order.dictionaryValue
		return request(.post, urlString: path, parameters: params, encoding: .json, headers: headers)
			.do(onNext: { (data) in
				let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
				log.info(json)
			})
			.map { try $0.decode() }
	}
	
	func orderPayment(with token: String, payment: Payment) -> Single<OrderPayment> {
		let path = APIModule.console + "/OrderPayment/Post"
		let headers: HTTPHeaders = [
			"Authorization": "MAuth \(token)"
		]
		let params = payment.dictionaryValue
		return request(.post, urlString: path, parameters: params, encoding: .json, headers: headers)
			.do(onNext: { (data) in
				let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
				log.info(json)
			})
			.map { try $0.decode() }
	}
}
