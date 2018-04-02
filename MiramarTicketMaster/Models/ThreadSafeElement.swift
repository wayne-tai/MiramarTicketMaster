//
//  ThreadSafeElement.swift
//  Cobinhood
//
//  Created by 𝕎𝔸𝕐ℕ𝔼 on 2018/3/21.
//  Copyright © 2018年 Cobinhood Inc. All rights reserved.
//

import Foundation

typealias SpinLock = NSRecursiveLock

final class ThreadSafeElement<Element> {
	
	private var _lock = SpinLock()
	
	private var _value: Element
	
	/// Initializes variable with initial value.
	///
	/// - parameter value: Initial variable value.
	public init(_ value: Element) {
		_value = value
	}
	
	/// Gets or sets current value of variable.
	internal var value: Element {
		get {
			_lock.lock(); defer { _lock.unlock() }
			return _value
		}
		set(newValue) {
			_lock.lock()
			_value = newValue
			_lock.unlock()
		}
	}
	
	
}
