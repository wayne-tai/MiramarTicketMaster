//
//  DataExtensions.swift
//  Cobinhood
//
//  Created by Wayne on 2017/9/26.
//  Copyright © 2017年 Cobinhood Inc. All rights reserved.
//

import Foundation

extension Data {
	
	/// Tranfer to `String` instance with UTF-8 string encoding
	internal var utf8StringValue: String {
		return self.string(encoding: .utf8) ?? ""
	}
}
