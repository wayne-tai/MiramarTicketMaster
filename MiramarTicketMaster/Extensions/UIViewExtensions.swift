//
//  UIViewExtensions.swift
//  Cobinhood
//
//  Created by 𝕎𝔸𝕐ℕ𝔼 on 2017/10/31.
//  Copyright © 2017年 Cobinhood Inc. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
	
	fileprivate class func delay(seconds: TimeInterval, completion: @escaping () -> Swift.Void ) {
		let delayTime = DispatchTime(uptimeNanoseconds: UInt64(seconds * 1000000))
		DispatchQueue.main.asyncAfter(deadline: delayTime) {
			completion()
		}
	}
	
	class func transition(from fromView: UIView, to toView: UIView, duration: TimeInterval, delay: TimeInterval, options: UIViewAnimationOptions = [], completion: ((Bool) -> Swift.Void)? = nil) {
		self.delay(seconds: delay) {
			UIView.transition(from: fromView, to: toView, duration: duration, options: options, completion: completion)
		}
	}
}
