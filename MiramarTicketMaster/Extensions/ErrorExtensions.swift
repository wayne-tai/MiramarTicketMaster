//
//  ErrorExtensions.swift
//  Cobinhood
//
//  Created by 𝕎𝔸𝕐ℕ𝔼 on 2017/11/9.
//  Copyright © 2017年 Cobinhood Inc. All rights reserved.
//

import Foundation

extension Error {
	
	internal var message: String? {
		if let _error = self as? ErrorStringConvertible {
			return _error.errorMessage
		}
		return localizedDescription
	}
}


extension Error {
	
	internal var code: Int {
		return (self as NSError).code
	}
	
	internal var userInfo: [String: Any] {
		return (self as NSError).userInfo
	}
	
	internal var failingURL: URL? {
		return ((self as NSError).userInfo[NSURLErrorFailingURLErrorKey] as? URL)
	}
}
