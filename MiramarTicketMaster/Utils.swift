//
//  Utils.swift
//  MiramarTicketMaster
//
//  Created by Wayne on 2018/3/26.
//  Copyright © 2018年 Wayne. All rights reserved.
//

import Foundation
import SwiftyBeaver

// MARK: Gloabl Vars
var log: SwiftyBeaver.Type = {
    SwiftyBeaver.addDestination(ConsoleDestination())
    return SwiftyBeaver.self
}()
