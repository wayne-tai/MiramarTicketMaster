//
//  StringExtensions.swift
//  Cobinhood
//
//  Created by Wayne on 2017/8/28.
//  Copyright © 2017年 Cobinhood Inc. All rights reserved.
//

import Foundation
import SwifterSwift

extension String {	
	var localized: String {
		return NSLocalizedString(self, comment: "")
	}
	
	func localized(with args: CVarArg...) -> String {
		let key = String(format: self.localized, arguments: args)
		return key
	}
	
	var decimal: Decimal? {
		return Decimal(string: self)
	}
	
	var decimalValue: Decimal {
		return self.decimal ?? Decimal(0)
	}
	
	var localizedDecimal: Decimal? {
		return Decimal(string: self, locale: Locale.current)
	}
	
	var localizedDecimalValue: Decimal? {
		return localizedDecimal ?? Decimal(0)
	}
    
    var intValue: Int {
        return self.int ?? 0
    }
	
	var doubleValue: Double {
		return Double(self) ?? 0.0
	}
	
	var base64Decode: Data? {
		let rem = self.characters.count % 4
		
		var ending = ""
		if rem > 0 {
			let amount = 4 - rem
			ending = String(repeating: "=", count: amount)
		}
		
		let base64 = self.replacingOccurrences(of: "-", with: "+", options: NSString.CompareOptions(rawValue: 0), range: nil)
			.replacingOccurrences(of: "_", with: "/", options: NSString.CompareOptions(rawValue: 0), range: nil) + ending
		
		return Data(base64Encoded: base64, options: Data.Base64DecodingOptions(rawValue: 0))
	}
}

extension String {
	
	func nsRange(from range: Range<Index>) -> NSRange {
		return NSRange(range, in: self)
	}
	
	func nsRange(of string: String, options: CompareOptions = .literal, range: Range<Index>? = nil, locale: Locale? = nil) -> NSRange? {
		guard let range = self.range(of: string, options: options, range: range ?? startIndex..<endIndex, locale: locale ?? .current) else {
			return nil
		}
		
		return NSRange(range, in: self)
	}
}

extension String {
	
	internal static var decimalCharacterSet: CharacterSet {
		/// Create characters with decimal numbers
		var set = CharacterSet(charactersIn: "1234567890")
		
		/// Add decimal separator to set
		if let decimalSeparator = Locale.current.decimalSeparator {
			set.insert(charactersIn: decimalSeparator)
		}
		
		/// Add grouping separator to set
        if let groupingSeparator = Locale.current.groupingSeparator {
            set.insert(charactersIn: groupingSeparator)
        }
		
		return set
	}
    
    internal static var decimalCharacterSetWithoutGroupingSeparator: CharacterSet {
        /// Create characters with decimal numbers
        var set = CharacterSet(charactersIn: "1234567890")
        
        /// Add decimal separator to set
        if let decimalSeparator = Locale.current.decimalSeparator {
            set.insert(charactersIn: decimalSeparator)
        }
        
        return set
    }
    
    internal var decimalOnly: String {
        let aSet = String.decimalCharacterSetWithoutGroupingSeparator.inverted
        let filtered = self.components(separatedBy: aSet).joined(separator: "")
        
        /// Separate string with decimal separator.
        var substrings = filtered.components(separatedBy: Locale.current.decimalSeparator ?? ".")
        
        /// Calculate how many invalud part should be removed.
        var removeCount = 0
        if substrings.count > 2 {
            removeCount = substrings.count - 2
        }
        
        /// Removes invalid exponent parts if needed.
        if removeCount > 0 {
            substrings = Array(substrings.dropLast(removeCount))
        }
        
        /// Handles the decimal number.
        if let decimalPart = substrings.first, decimalPart.count > 1 {
            /// Removes the zeros at the beginning of the decimal number string.
            var _decimalPart = decimalPart
            for character in decimalPart {
                guard character == "0" else {
                    break
                }
                _decimalPart.removeFirst()
            }
            substrings.replaceSubrange(0...0, with: [_decimalPart])
        }
        
        return substrings.joined(separator: Locale.current.decimalSeparator ?? ".")
    }
    
    internal var decimalWithGrouping: String {
        let aSet = String.decimalCharacterSetWithoutGroupingSeparator.inverted
        let filtered = self.components(separatedBy: aSet).joined(separator: "")
        
        /// Separate string with decimal separator.
        let substrings = filtered.components(separatedBy: Locale.current.decimalSeparator ?? ".")
        var newDecimalString: String
        var newDecimalPart = [String]()
        
        /// Handles the decimal number.
        if var decimalPart = substrings.first {
            /// Removes the zeros at the beginning of the decimal number string.
            if decimalPart.count > 1 {
                var _decimalPart = decimalPart
                for character in decimalPart {
                    guard character == "0" else {
                        break
                    }
                    _decimalPart.removeFirst()
                }
                decimalPart = _decimalPart
            }
            
            /// Create new decimal part with grouping size 3
            var count = 0
            
            for (idx, character) in decimalPart.reversed().enumerated() {
                newDecimalPart.append(String(character))
                count += 1
                
                /// Check if current character is the last one.
                if idx == (decimalPart.count - 1) {
                    break
                }
                
                /// Determine if grouping separator is needed.
                if count % 3 == 0 {
                    newDecimalPart.append(Locale.current.groupingSeparator ?? ",")
                    count = 0
                }
            }
        }
        
        /// Reverse the new decimal part will get the original number with grouping separator added.
        newDecimalString = newDecimalPart.reversed().joined(separator: "")
        
        /// Check if exponent part is existed.
        /// If true, appends the exponent part with decimal separator.
        if substrings.count > 1 {
            let exponentPart = substrings[1]
            newDecimalString += ((Locale.current.decimalSeparator ?? ".") + exponentPart)
        }
        
        return newDecimalString
    }
    
    internal func discardZeroExponents() -> String {
        let aSet = String.decimalCharacterSet.inverted
        let filtered = self.components(separatedBy: aSet).joined(separator: "")
        
        /// Separate string with decimal separator.
        let substrings = filtered.components(separatedBy: Locale.current.decimalSeparator ?? ".")
        var newDecimalString = substrings.first ?? ""
        
        /// Remove zeros from the end of exponent, and stop when meet first non-zero digit.
        if substrings.count > 1 {
            var exponentPart = substrings[1]
            for character in substrings[1].reversed() {
                if character == "0" {
                    exponentPart.removeLast()
                } else {
                    break
                }
            }
            
            /// If exponent is not zero, appends the the end of the decimal number.
            if exponentPart.count > 0 {
                newDecimalString += ((Locale.current.decimalSeparator ?? ".") + exponentPart)
            }
        }
        
        return newDecimalString
    }
}
