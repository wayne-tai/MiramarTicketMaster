//
//  NetworkReachabilityManagerExtensions.swift
//  Cobinhood
//
//  Created by Wayne on 2018/3/12.
//  Copyright © 2018年 Cobinhood Inc. All rights reserved.
//

import Foundation
import Alamofire

extension NetworkReachabilityManager {
    
    internal static let shared: NetworkReachabilityManager? = {
        let manager = NetworkReachabilityManager()
        manager?.listener = { (status) in
            if case .reachable = status {
                log.info("Network status is changed to reachable.")
                NotificationCenter.default.post(name: .CBNetworkChangeToReachable, object: nil)
            } else {
                log.info("Network status is changed to unreachable.")
                NotificationCenter.default.post(name: .CBNetworkChangeToUnreachable, object: nil)
            }
        }
        
        return manager
    }()
}

protocol NetworkReachabilityProvider {
    
    var isReachable: Bool { get }
}

extension NetworkReachabilityManager: NetworkReachabilityProvider { }
