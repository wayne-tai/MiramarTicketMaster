//
//  UIColorExtensions.swift
//  Cobinhood
//
//  Created by Wayne on 2017/8/29.
//  Copyright © 2017年 Cobinhood Inc. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    struct cobinhood {
		
        static let green: UIColor = UIColor(red: 19.0 / 255.0, green: 191.0 / 255.0, blue: 153.0 / 255.0, alpha: 1.0)
		static let darkGreen: UIColor = UIColor(red: 63.0 / 255.0, green: 160.0 / 255.0, blue: 138.0 / 255.0, alpha: 1.0)
        static let lightGray: UIColor = UIColor(red: 38.0 / 255.0, green: 52.0 / 255.0, blue: 60.0 / 255.0, alpha: 1.0)
        static let darkGray: UIColor = UIColor(red: 18.0 / 255.0, green: 32.0 / 255.0, blue: 40.0 / 255.0, alpha: 1.0)
        static let red: UIColor = UIColor(red: 255.0 / 255.0, green: 67.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0)
		static let darkRed: UIColor = UIColor(red: 213.0 / 255.0, green: 58.0 / 255.0, blue: 67.0 / 255.0, alpha: 1.0)
        static let slateGrey: UIColor = UIColor(red: 94.0 / 255.0, green: 108.0 / 255.0, blue: 117.0 / 255.0, alpha: 1.0)
        static let blueGrey: UIColor = UIColor(red: 170.0 / 255.0, green: 185.0 / 255.0, blue: 194.0 / 255.0, alpha: 1.0)
        static let purpleyGrey: UIColor = UIColor(red: 155.0 / 255.0, green: 155.0 / 255.0, blue: 155.0 / 255.0, alpha: 1.0)
        static let charcoalGrey: UIColor = UIColor(red: 74.0 / 255.0, green: 74.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0)
        static let dark: UIColor = UIColor(red: 27.0 / 255.0, green: 41.0 / 255.0, blue: 49.0 / 255.0, alpha: 1.0)
        static let squash: UIColor = UIColor(red: 245.0 / 255.0, green: 166.0 / 255.0, blue: 35.0 / 255.0, alpha: 1.0)
		static let separator: UIColor = UIColor(red: 54.0/255.0, green: 62.0/255.0, blue: 67.0/255.0, alpha: 1.0)
		static let alertBackground = UIColor(red:195.0/255.0, green:206.0/255.0, blue:212.0/255.0, alpha:1.00)
		static let webBackground = UIColor(red: 27.0/255.0, green: 41.0/255.0, blue: 49.0/255.0, alpha: 1.0)
		
    }
}

extension UIColor {
	
	struct Cobinhood: RawRepresentable {
		var rawValue: UIColor
		
		init(rawValue: UIColor) {
			self.rawValue = rawValue
		}
		
		init(_ rawValue: UIColor) {
			self = Cobinhood(rawValue: rawValue)
		}
		
		var alpha: CGFloat {
			get {
				return self.rawValue.alpha
			}
			set {
				self.rawValue = self.rawValue.withAlphaComponent(newValue)
			}
		}
		
		func with(alpha: CGFloat) -> Cobinhood {
			return Cobinhood(rawValue.withAlphaComponent(alpha))
		}
	}
}

extension UIColor.Cobinhood {
	
	static let green			= UIColor.Cobinhood(UIColor(red: 19.0 / 255.0, green: 191.0 / 255.0, blue: 153.0 / 255.0, alpha: 1.0))
	static let darkGreen		= UIColor.Cobinhood(UIColor(red: 63.0 / 255.0, green: 160.0 / 255.0, blue: 138.0 / 255.0, alpha: 1.0))
	static let lightGray		= UIColor.Cobinhood(UIColor(red: 38.0 / 255.0, green: 52.0 / 255.0, blue: 60.0 / 255.0, alpha: 1.0))
	static let darkGray			= UIColor.Cobinhood(UIColor(red: 18.0 / 255.0, green: 32.0 / 255.0, blue: 40.0 / 255.0, alpha: 1.0))
	static let red				= UIColor.Cobinhood(UIColor(red: 255.0 / 255.0, green: 67.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0))
	static let darkRed			= UIColor.Cobinhood(UIColor(red: 213.0 / 255.0, green: 58.0 / 255.0, blue: 67.0 / 255.0, alpha: 1.0))
	static let slateGrey		= UIColor.Cobinhood(UIColor(red: 94.0 / 255.0, green: 108.0 / 255.0, blue: 117.0 / 255.0, alpha: 1.0))
	static let blueGrey			= UIColor.Cobinhood(UIColor(red: 170.0 / 255.0, green: 185.0 / 255.0, blue: 194.0 / 255.0, alpha: 1.0))
	static let purpleyGrey		= UIColor.Cobinhood(UIColor(red: 155.0 / 255.0, green: 155.0 / 255.0, blue: 155.0 / 255.0, alpha: 1.0))
	static let charcoalGrey		= UIColor.Cobinhood(UIColor(red: 74.0 / 255.0, green: 74.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0))
	static let dark				= UIColor.Cobinhood(UIColor(red: 27.0 / 255.0, green: 41.0 / 255.0, blue: 49.0 / 255.0, alpha: 1.0))
	static let squash			= UIColor.Cobinhood(UIColor(red: 245.0 / 255.0, green: 166.0 / 255.0, blue: 35.0 / 255.0, alpha: 1.0))
	static let separator		= UIColor.Cobinhood(UIColor(red: 54.0/255.0, green: 62.0/255.0, blue: 67.0/255.0, alpha: 1.0))
	static let alertBackground	= UIColor.Cobinhood(UIColor(red: 195.0/255.0, green: 206.0/255.0, blue: 212.0/255.0, alpha: 1.0))
	static let webBackground	= UIColor.Cobinhood(UIColor(red: 27.0/255.0, green: 41.0/255.0, blue: 49.0/255.0, alpha: 1.0))
	
}
