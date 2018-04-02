//
//  UIFontExtensions.swift
//  Cobinhood
//
//  Created by Wayne on 2017/8/28.
//  Copyright © 2017年 Cobinhood Inc. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
	
	fileprivate static var cobinhoodFontName: String {
		return "SFPro"
	}
	
	enum Family: String {
		case text = "Text"
		case display = "Display"
	}
	
	enum WeightStyle: String {
		case ultraLight = "Ultralight"
		case thin = "Thin"
		case light = "Light"
		case regular = "Regular"
		case medium = "Medium"
		case semibold = "Semibold"
		case bold = "Bold"
		case heavy = "Heavy"
		case black = "Black"
	}
	
	// MARK: -
	// MARK: Default Font
	
	class func defaultFont(ofSize size: CGFloat, family: Family? = nil, weight: WeightStyle = .regular) -> UIFont {
		// For font size > 19, use Display family font
		let fontFamily = family ?? (size < 20.0 ? .text : .display)
		
		return UIFont(name: "\(cobinhoodFontName)\(fontFamily.rawValue)-\(weight.rawValue)", size: size) ?? UIFont.systemFont(ofSize: size)
	}
	
	class func defaultDisplayFont(ofSize size: CGFloat, weight: WeightStyle = .regular) -> UIFont {
		return UIFont.defaultFont(ofSize: size, family: .display, weight: weight)
	}
	
	class func defaultTextFont(ofSize size: CGFloat, weight: WeightStyle = .regular) -> UIFont {
		return UIFont.defaultFont(ofSize: size, family: .text, weight: weight)
	}
	
	// MARK: -
	// MARK: Default Italic Font
	
	class func defaultItalicFont(ofSize size: CGFloat, family: Family? = nil, weight: WeightStyle = .regular) -> UIFont {
		// For font size > 19, use Display family font
		let fontFamily = family ?? (size < 20.0 ? .text : .display)
		
		return UIFont(name: "\(cobinhoodFontName)\(fontFamily.rawValue)-\(weight.rawValue)Italic", size: size) ?? UIFont.italicSystemFont(ofSize: size)
	}
	
	class func defaultItalicDisplayFont(ofSize size: CGFloat, weight: WeightStyle) -> UIFont {
		return UIFont.defaultItalicFont(ofSize: size, family: .display, weight: weight)
	}
	
	class func defaultItalicTextFont(ofSize size: CGFloat, weight: WeightStyle) -> UIFont {
		return UIFont.defaultItalicFont(ofSize: size, family: .text, weight: weight)
	}
	
	// MARK: -
	// MARK: Other Fonts
	
	static func PingFangTC(ofSize size: CGFloat, weight: WeightStyle) -> UIFont {
		return UIFont(name: "PingFangTC-\(weight.rawValue)", size: size) ?? UIFont.systemFont(ofSize: size)
	}
	
	static func arialMT(ofSize size: CGFloat) -> UIFont {
		return UIFont(name: "ArialMT", size: size) ?? UIFont.systemFont(ofSize: size)
	}
	
	static func arialBoldMT(ofSize size: CGFloat) -> UIFont {
		return UIFont(name: "Arial-BoldMT", size: size) ?? UIFont.systemFont(ofSize: size)
	}
}
