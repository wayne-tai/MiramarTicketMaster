//
//  Notification.swift
//  Cobinhood
//
//  Created by 𝕎𝔸𝕐ℕ𝔼 on 2017/10/31.
//  Copyright © 2017年 Cobinhood Inc. All rights reserved.
//

import Foundation

extension Notification.Name {
	
	/// User login
	static let CBUserWillLogIn = Notification.Name(rawValue: "CBUserWillLogIn")
	static let CBUserDidLogIn = Notification.Name(rawValue: "CBUserDidLogIn")
	
	/// User logout
	static let CBUserWillLogout = Notification.Name(rawValue: "CBUserWillLogout")
	static let CBUserDidLogout = Notification.Name(rawValue: "CBUserDidLogout")
	
	/// Order state updated
	static let CBDidOrderCompleted = Notification.Name(rawValue: "CBDidOrderCompleted")
	static let CBDidOrderPlaced = Notification.Name(rawValue: "CBDidOrderPlaced")
	static let CBDidOrderModified = Notification.Name(rawValue: "CBDidOrderModified")
	static let CBDidOrderCancelled = Notification.Name(rawValue: "CBDidOrderCancelled")
    
    /// Trading pair updated
    static let CBDidGetTradingPairId = Notification.Name(rawValue: "CBDidGetTradingPairId")

	/// Device verification confirmed
	static let CBDidConfirmDeviceVerification = Notification.Name(rawValue: "CBDidConfirmDeviceVerification")
	
	/// Application State
	static let CBApplicationWillEnterForeground = Notification.Name(rawValue: "CBApplicationWillEnterForeground")
    
    /// Network Status
    static let CBNetworkChangeToReachable = Notification.Name(rawValue: "CBNetworkChangeToReachable")
    static let CBNetworkChangeToUnreachable = Notification.Name(rawValue: "CBNetworkChangeToUnreachable")
	
	/// Others
	static let CBDidGenerateDeciveId = Notification.Name(rawValue: "CBDidGenerateDeciveId")
    static let CBDidGetUserInfo = Notification.Name(rawValue: "CBDidGetUserInfo")
}
