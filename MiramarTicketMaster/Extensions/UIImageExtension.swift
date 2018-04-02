//
//  UIImageExtension.swift
//  Cobinhood
//
//  Created by Hao Chang on 11/09/2017.
//  Copyright © 2017 Cobinhood Inc. All rights reserved.
//

import UIKit

extension UIImage {
    static var cob: UIImage? {
        return UIImage(named: "cob")
    }
    static var ogreenup: UIImage? {
        return UIImage(named: "ogreenup")
    }
    static var oreddown: UIImage? {
        return UIImage(named: "oreddown")
    }
    static var arrowdown2: UIImage? {
        return UIImage(named: "arrowdown2")
    }
    static var close: UIImage? {
        return UIImage(named: "close")
    }
    static var drawer: UIImage? {
        return UIImage(named: "drawer")
    }
    static var closedown: UIImage? {
        return UIImage(named: "closedown")
    }
    static var ic_contact: UIImage? {
        return UIImage(named: "ic_contact")
    }
    static var ic_gAuth: UIImage? {
        return UIImage(named: "ic_gAuth")
    }
    static var ic_lock: UIImage? {
        return UIImage(named: "ic_lock")
    }
    static var ic_logout: UIImage? {
        return UIImage(named: "ic_logout")
    }
    static var ic_privacy: UIImage? {
        return UIImage(named: "ic_privacy")
    }
    static var ic_SMS: UIImage? {
        return UIImage(named: "ic_SMS")
    }
    static var ic_terms: UIImage? {
        return UIImage(named: "ic_terms")
    }
    static var ic: UIImage? {
        return UIImage(named: "ic")
    }
    static var Group: UIImage? {
        return UIImage(named: "Group")
    }
    static var settings: UIImage? {
        return UIImage(named: "settings")
    }
    static var off: UIImage? {
        return UIImage(named: "off")
    }
    static var close_round: UIImage? {
        return UIImage(named: "close_round")
    }
    static var plus: UIImage? {
        return UIImage(named: "plus")
    }
    static var qrcode_FontAwesome: UIImage? {
        return UIImage(named: "qrcode_FontAwesome")
    }
    static var logo200: UIImage? {
        return UIImage(named: "logo200")
    }
    static var ic_see_disabled: UIImage? {
        return UIImage(named: "ic_see_disabled")
    }
    static var plus_circle: UIImage? {
        return UIImage(named: "plus_circle")
    }
    static var minus_circle: UIImage? {
        return UIImage(named: "minus_circle")
    }
    static var bitcoin: UIImage? {
        return UIImage(named: "bitcoin")
    }
    static var ether: UIImage? {
        return UIImage(named: "ether")
    }
    static var tether: UIImage? {
        return UIImage(named: "tether")
    }
    static var filter: UIImage? {
        return UIImage(named: "filter")
    }
    static var cancel: UIImage? {
        return UIImage(named: "cancel")
    }
	static var usd: UIImage? {
		return UIImage(named: "usd")
	}
	static var verifyEmail: UIImage? {
		return UIImage(named: "verify_email")
	}
	static var idFront: UIImage? {
		return UIImage(named: "idFront")
	}
    static var idBack: UIImage? {
        return UIImage(named: "idBack")
    }
    static var passport_cover: UIImage? {
        return UIImage(named: "passport_cover")
    }
    static var authPhoto: UIImage? {
        return UIImage(named: "authPhoto")
    }
	static var ic_down: UIImage? {
		return UIImage(named: "ic_down")
	}
	static var starIcon: UIImage? {
		return UIImage(named: "ic_star")
	}
	static var selectedStarIcon: UIImage? {
		return UIImage(named: "ic_star_selected")
	}
    static var selectedStarIconSmall: UIImage? {
        return UIImage(named: "ic_star_selected_small")
    }
	static var ic_edit: UIImage? {
		return UIImage(named: "ic_edit")
	}
	static var ic_coin_cob: UIImage? {
		return UIImage(named: "ic_coin_cob")
	}
    static var ic_search: UIImage? {
        return UIImage(named: "ic_search")
    }
    static var ic_search_small: UIImage? {
        return UIImage(named: "ic_search_small")
    }
	static var ic_info: UIImage? {
		return UIImage(named: "ic_info")
	}
}

extension UIImage {
	
	internal var originalRender: UIImage {
		return self.withRenderingMode(.alwaysOriginal)
	}
}

extension UIImage {
	
	internal var dataSize: Int {
		guard let data = UIImagePNGRepresentation(self) else {
			return 0
		}
		return data.count
	}
	
	internal func resize(with scale: CGFloat) -> UIImage? {
		let size = self.size.applying(CGAffineTransform(scaleX: scale, y: scale))
		return resize(to: size)
	}
	
	internal func resize(to size: CGSize) -> UIImage? {
		UIGraphicsBeginImageContext(size)
		self.draw(in: CGRect(origin: CGPoint.zero, size: size))
		
		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return newImage
	}
}
