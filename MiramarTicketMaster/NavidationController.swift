//
//  NavidationController.swift
//  MiramarTicketMaster
//
//  Created by Wayne on 2019/4/12.
//  Copyright © 2019 Wayne. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // title text color
        navigationBar.tintColor = .black
        navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.black,
            .font: UIFont.defaultDisplayFont(ofSize: 18, weight: .semibold)
        ]
        
        // background
        navigationBar.barTintColor = .clear
        navigationBar.isTranslucent = true
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        // shadow
        navigationBar.shadowImage = UIImage()
    }
}
