//
//  UIResponderExtension.swift
//  Being
//
//  Created by Shiva Huang on 2017/4/27.
//  Copyright © 2017 Shiva Huang. All rights reserved.
//

import Foundation
import UIKit

// REF: http://stackoverflow.com/a/37492338/2467590
private weak var currentFirstResponder: UIResponder?

extension UIResponder {
    
    static func firstResponder() -> UIResponder? {
        currentFirstResponder = nil
        UIApplication.shared.sendAction(#selector(self.findFirstResponder(sender:)), to: nil, from: nil, for: nil)
        return currentFirstResponder
    }
    
    @objc func findFirstResponder(sender: AnyObject) {
        currentFirstResponder = self
    }
    
}
