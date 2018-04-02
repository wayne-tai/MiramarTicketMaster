//
//  ServiceModule.swift
//  MiramarTicketMaster
//
//  Created by Wayne on 2018/3/27.
//  Copyright © 2018年 Wayne. All rights reserved.
//

import Foundation
import RxSwift
import typealias Alamofire.Parameters

extension API {
    
    internal static func getAnnounce() -> Observable<Key> {
        let path = APIModule.service + "/Announce"
        let params = ["AppVersion": Environments.LocalInfo.AppVersion,
                      "DeviceId": Environments.LocalInfo.DeviceId,
                      "DeviceType": Environments.LocalInfo.DeviceType,
                      "DeviceUID": Environments.LocalInfo.DeviceUID]
        
        let headers = ["Host": "www.miramarcinemas.com.tw"]
        
        return request(.post, urlString: path, parameters: params, headers: headers)
            .map { try Key.key(from: $0) }
    }
    
    internal static func getShowTime(with key: String) -> Observable<[Cinema]> {
        let path = APIModule.service + "/QuickOrderShowTime"
        let params = ["Captcha": Environments.LocalInfo.Captcha,
                      "DeviceId": Environments.LocalInfo.DeviceId,
                      "DeviceType": Environments.LocalInfo.DeviceType,
                      "Key": key]
        
        let headers = ["Host": "www.miramarcinemas.com.tw"]
        
        return request(.post, urlString: path, parameters: params, headers: headers)
            .map { try Cinema.cinemas(from: $0) }
    }
    
    internal static func getTicketTypes(with key: String, cinemaId: String, sessionId: String) -> Observable<[TicketType]> {
        let path = APIModule.service + "/TicketType"
        let params = ["Captcha": Environments.LocalInfo.Captcha,
                      "CinemaId": cinemaId,
                      "DeviceId": Environments.LocalInfo.DeviceId,
                      "DeviceType": Environments.LocalInfo.DeviceType,
                      "Key": key,
                      "SessionId": sessionId]
        
        let headers = ["Host": "www.miramarcinemas.com.tw"]
        
        return request(.post, urlString: path, parameters: params, headers: headers)
            .map { try TicketType.ticketTypes(from: $0) }
    }
    
    internal static func getSessionSeatData(with key: String, cinemaId: String, sessionId: String, ticketTypeJson: String) -> Observable<[Area]> {
        let path = APIModule.service + "/SessionSeatData"
        let params = ["Captcha": Environments.LocalInfo.Captcha,
                      "CinemaId": cinemaId,
                      "DeviceId": Environments.LocalInfo.DeviceId,
                      "DeviceType": Environments.LocalInfo.DeviceType,
                      "Key": key,
                      "SessionId": sessionId,
                      "TicketTypeJson": ticketTypeJson,
                      "UserSessionId": Environments.LocalInfo.UserSessionId]
        
        let headers = ["Host": "www.miramarcinemas.com.tw"]
        
        return request(.post, urlString: path, parameters: params, headers: headers)
            .map { try Area.areas(from: $0) }
    }
    
    internal static func setSelectedSeat(with key: String, cinemaId: String, sessionId: String, selectedSeatJson: String) -> Observable<OrderConfirm> {
        let path = APIModule.service + "/SetSelectedSeat"
        let params = ["Captcha": Environments.LocalInfo.Captcha,
                      "CinemaId": cinemaId,
                      "DeviceId": Environments.LocalInfo.DeviceId,
                      "DeviceType": Environments.LocalInfo.DeviceType,
                      "Key": key,
                      "SessionId": sessionId,
                      "SelectedSeatJson": selectedSeatJson,
                      "UserSessionId": Environments.LocalInfo.UserSessionId]
        
        let headers = ["Host": "www.miramarcinemas.com.tw"]
        
        return request(.post, urlString: path, parameters: params, headers: headers)
            .map { try OrderConfirm.orderConfirm(from: $0) }
    }
    
    internal static func completeOrder(with key: String, cinemaId: String, sessionId: String, paymentValue: Int) -> Observable<OrderResult> {
        let path = APIModule.service + "/CompleteOrder"
        let params: Parameters = ["Captcha": Environments.LocalInfo.Captcha,
                                  "CinemaId": cinemaId,
                                  "CompleteFrom": Environments.LocalInfo.CompleteFrom,
                                  "CustomerEmail": Environments.LocalInfo.CustomerEmail,
                                  "CustomerName": Environments.LocalInfo.CustomerName,
                                  "CustomerPhone": Environments.LocalInfo.CustomerPhone,
                                  "DeviceId": Environments.LocalInfo.DeviceId,
                                  "DeviceType": Environments.LocalInfo.DeviceType,
                                  "Key": key,
                                  "MemberId": Environments.LocalInfo.MemberId,
                                  "SessionId": sessionId,
                                  "PaymentValue": paymentValue,
                                  "UserSessionId": Environments.LocalInfo.UserSessionId]
        
        let headers = ["Host": "www.miramarcinemas.com.tw"]
        
        return request(.post, urlString: path, parameters: params, headers: headers)
            .map { try OrderResult.result(from: $0) }
    }
}
