//
//  DecoderExtensions.swift
//  Cobinhood
//
//  Created by 𝕎𝔸𝕐ℕ𝔼 on 2018/2/6.
//  Copyright © 2018年 Cobinhood Inc. All rights reserved.
//

import Foundation

extension Decodable {
	
	/// This is currently not used in project.
	static func decode(with decoder: JSONDecoder = JSONDecoder(), from data: Data) throws -> Self {
		return try decoder.decode(Self.self, from: data)
	}
}

