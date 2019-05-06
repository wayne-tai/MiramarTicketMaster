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

extension UIView {
	
	enum SpacerProperty {
		case vertical(CGFloat)
		case horizontal(CGFloat)
	}
	
	static func spacer(_ property: SpacerProperty) -> UIView {
		let view = UIView()
		view.backgroundColor = .clear
		view.snp.makeConstraints { (maker) in
			if case .horizontal(let spacing) = property {
				maker.height.equalTo(spacing)
			}
			if case .vertical(let spacing) = property {
				maker.width.equalTo(spacing)
			}
		}
		return view
	}
}

extension UIView {
    
    enum ShadowStyle {
        case normal
        case light
        
        var shadowColor: UIColor {
            return .black
        }
        
        var shadowOffset: CGSize {
            switch self {
            case .normal: return CGSize(width: 2.0, height: 2.0)
            case .light: return CGSize(width: 2.0, height: 2.0)
            }
        }
        
        var shadowRadius: CGFloat {
            switch self {
            case .normal: return 5.0
            case .light: return 2.5
            }
        }
        
        var shadowOpacity: Float {
            switch self {
            case .normal: return 0.5
            case .light: return 0.25
            }
        }
    }
    
    func applyShadow(style: ShadowStyle) {
        layer.shadowColor = style.shadowColor.cgColor
        layer.shadowOffset = style.shadowOffset
        layer.shadowRadius = style.shadowRadius
        layer.shadowOpacity = style.shadowOpacity
        clipsToBounds = false
    }
}
