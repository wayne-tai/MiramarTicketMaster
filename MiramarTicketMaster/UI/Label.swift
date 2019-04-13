//
//  Label.swift
//  MiramarTicketMaster
//
//  Created by 𝕎𝔸𝕐ℕ𝔼 on 2019/4/13.
//  Copyright © 2019 Wayne. All rights reserved.
//

import UIKit

class Label: UILabel {

	private struct Layout {
		static let margin = UIEdgeInsets.zero
	}

	var margin: UIEdgeInsets = Layout.margin {
		didSet { setNeedsDisplay() }
	}
	
	override func drawText(in rect: CGRect) {
		super.drawText(in: UIEdgeInsetsInsetRect(rect, margin))
	}
}
