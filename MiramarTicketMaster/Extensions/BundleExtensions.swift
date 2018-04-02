//
//  BundleExtensions.swift
//  Cobinhood
//
//  Created by 𝕎𝔸𝕐ℕ𝔼 on 2018/2/8.
//  Copyright © 2018年 Cobinhood Inc. All rights reserved.
//

import Foundation

extension Bundle {
	
	internal static var appVersion: String {
		return self.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
	}
	
	internal static var buildNumber: Int {
		return (self.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String).intValue
	}
}
