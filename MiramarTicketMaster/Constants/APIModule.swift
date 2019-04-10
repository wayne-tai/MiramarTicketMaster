//
//  APIModule.swift
//  Cobinhood
//
//  Created by 𝕎𝔸𝕐ℕ𝔼 on 2017/10/5.
//  Copyright © 2017年 Cobinhood Inc. All rights reserved.
//

import Foundation

/// Represent the router type by API module
internal enum APIModule: String {
	case console = "/MiramarDazhiVistaConsole/api"
}

extension APIModule {
	internal static func + (lft: APIModule, rht: String) -> String {
		return lft.rawValue + rht
	}
}
