//
//  SingleExtensions.swift
//  MiramarTicketMaster
//
//  Created by 𝕎𝔸𝕐ℕ𝔼 on 2019/4/10.
//  Copyright © 2019 Wayne. All rights reserved.
//

import Foundation
import RxSwift
import enum Alamofire.Result

extension PrimitiveSequence where TraitType == SingleTrait {
	
	internal func toResult() -> Single<Result<Element>> {
		return self.map { .success($0) }
			.catchError { .just(.failure($0)) }
	}
}

