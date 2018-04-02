//
//  CellExtensions.swift
//  Cobinhood
//
//  Created by Wayne on 2017/8/28.
//  Copyright © 2017年 Cobinhood Inc. All rights reserved.
//

import Foundation
import UIKit

extension UITableViewCell {
	
	class func identifier<T: UIView>(for viewType: T.Type) -> String {
		return String(describing: viewType)
	}
	
	static var cellIdentifier: String {
		return identifier(for: self)
	}
	
	static var nibName: String {
		return identifier(for: self)
	}
}

extension UICollectionViewCell {
	
	class func identifier<T: UIView>(for viewType: T.Type) -> String {
		return String(describing: viewType)
	}
	
	static var cellIdentifier: String {
		return identifier(for: self)
	}
	
	static var nibName: String {
		return identifier(for: self)
	}
}
