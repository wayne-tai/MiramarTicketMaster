//
//  UIButtonExtensions.swift
//  Cobinhood
//
//  Created by Wayne on 2017/8/31.
//  Copyright © 2017年 Cobinhood Inc. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
	
	var titleFont: UIFont? {
		get {
			guard let label = self.titleLabel else { return nil }
			return label.font
		}
		set {
			titleLabel?.font = newValue
		}
	}
}

extension UIButton {
	
	enum Transparency {
		case none
		case low
		case middle
		case high
		case full
		case custom(CGFloat)
		
		var value: CGFloat {
			switch self {
			case .none: return 0.0
			case .low: return 0.25
			case .middle: return 0.5
			case .high: return 0.75
			case .full: return 1.0
			case .custom(let value): return value
			}
		}
	}
	
	internal func setEnable() {
		self.isEnabled = true
		self.alpha = 1.0
	}
	
	internal func setDisable(with transparency: Transparency = .middle) {
		self.isEnabled = false
		self.alpha = transparency.value
	}
}
