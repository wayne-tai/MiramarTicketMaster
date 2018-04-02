//
//  NSAttributedStringExtensions.swift
//  Cobinhood
//
//  Created by 𝕎𝔸𝕐ℕ𝔼 on 2017/11/13.
//  Copyright © 2017年 Cobinhood Inc. All rights reserved.
//

import Foundation
import UIKit

extension NSAttributedString {
	
	convenience init(string: String,
	                 font: UIFont? = nil,
	                 color: UIColor? = nil,
	                 textAlignment: NSTextAlignment? = nil,
	                 lineSpacing: CGFloat? = nil){
		var attribute: [NSAttributedStringKey:Any] = [:]
		attribute[NSAttributedStringKey.font] = font
		attribute[NSAttributedStringKey.foregroundColor] = color
		var style: NSMutableParagraphStyle? = nil
		if let textAlignment = textAlignment {
			if style == nil {
				style = NSMutableParagraphStyle()
			}
			style?.alignment = textAlignment
		}
		if let lineSpacing = lineSpacing {
			if style == nil {
				style = NSMutableParagraphStyle()
			}
			style?.lineSpacing = lineSpacing
		}
		
		attribute[NSAttributedStringKey.paragraphStyle] = style
		self.init(string: string, attributes: attribute)
	}
	
}

extension NSAttributedString {
	
	func range(of string: String) -> Range<String.Index>? {
		return self.string.range(of: string)
	}
	
	func range(of string: String) -> NSRange? {
		return self.string.nsRange(of: string)
	}
}

extension NSMutableAttributedString {
	
	internal func apply(attributes: [NSAttributedStringKey: Any]?, to text: String) {
		guard let _attributes = attributes else {
			return
		}
		
		guard let range: NSRange = self.range(of: text) else {
			return
		}
		
		self.addAttributes(_attributes, range: range)
	}
	
}
