//
//  Environments.swift
//  Cobinhood
//
//  Created by Wayne on 2017/8/15.
//  Copyright © 2017年 Cobinhood Inc. All rights reserved.
//

import Foundation

struct Environments {
	
	struct Url {
		static let Base = "https://www.miramarcinemas.com.tw"
		static let Domain = "https://www.miramarcinemas.com.tw"
	}
	
	struct UserDefaultsKey {
		static let Key = "key"
        static let Cinemas = "cinemas"
        static let CinemaId = "cinemaId"
        static let SessionId = "sessionId"
        static let TicketTypeJson = "ticketTypeJson"
        static let SelectedSeatsJson = "selectedSeatsJson"
	}
    
    struct LocalInfo {
        static let AppVersion = "5.1.6"
        static let Captcha = "05C65B9C5AEE5E57645AB1B3AFAA8601"
//        static let Captcha = "502798DF1167DDC46B53D4942C02AC5C"
//        static let Captcha = "D7E10F08CD0B2A4806D23AFFE1029781"
        static let DeviceId = "adfefa4b7d19f0d69b99f74b86edb03853d9514b"
        static let DeviceType = "1"
        static let DeviceUID = "2FA79CE1A28446CEACBD94D165596AAA"
        static let UserSessionId = "2E2A7E1F714E4FACBDDD9ADD4C5A0426"
//        static let UserSessionId = "4AEBDED848B84E2AAF5757FF9780C52E"
//        static let UserSessionId = "EA82D983935E43DC9CFC138C26F7E3BE"
        static let CompleteFrom = 2
        static let CustomerEmail = "wudypig@gmail.com"
        static let CustomerName = "戴 宏偉"
        static let CustomerPhone = "0939930939"
        static let MemberId = "MFC99CS62FPWG"
    }
}
