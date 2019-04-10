//
//  ViewModel.swift
//  MiramarTicketMaster
//
//  Created by 𝕎𝔸𝕐ℕ𝔼 on 2019/4/10.
//  Copyright © 2019 Wayne. All rights reserved.
//

import Foundation

protocol ViewModel: AnyObject {
	var logger: ViewModelLogger? { get }
	func start()
}

protocol ViewModelLogger: AnyObject {
	func log(_ text: String)
}


class EmptyViewModel: ViewModel {
	
	var logger: ViewModelLogger?
	
	func start() {
		
	}
}
