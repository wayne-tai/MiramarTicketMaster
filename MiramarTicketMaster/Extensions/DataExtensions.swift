//
//  DataExtensions.swift
//  Cobinhood
//
//  Created by Wayne on 2017/9/26.
//  Copyright © 2017年 Cobinhood Inc. All rights reserved.
//

import Foundation
import enum Alamofire.Result

extension Data {
	
	/// Tranfer to `String` instance with UTF-8 string encoding
	internal var utf8StringValue: String {
		return self.string(encoding: .utf8) ?? ""
	}
}

typealias DataResult = Result<Data>

extension Data {
	
	/// This is currently not used in project.
	func decode<Object>(with decoder: JSONDecoder = JSONDecoder()) throws -> Object where Object: Decodable {
		return try Object.decode(with: decoder, from: self)
	}
}
