//
//  DispatchQueueExtensions.swift
//  Cobinhood
//
//  Created by 𝕎𝔸𝕐ℕ𝔼 on 2017/12/1.
//  Copyright © 2017年 Cobinhood Inc. All rights reserved.
//

import Foundation

extension DispatchQueue {
	private static var token: DispatchSpecificKey<String> = {
		let key = DispatchSpecificKey<String>()
		DispatchQueue.main.setSpecific(key: key, value: "Main")
		return key
	}()
	
	static var isMain: Bool {
		return DispatchQueue.getSpecific(key: token) != nil
	}
}
