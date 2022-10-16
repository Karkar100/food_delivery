//
//  UIColor+HEX+RGBA.swift
//  Coffee&Co Delivery
//
//  Created by Diana Princess on 15.10.2022.
//

import Foundation
import UIKit

extension UIColor{
    
    
    public convenience init(hex: String) {
        let hex = (hex ?? "")
                .replacingOccurrences(of: "#", with: "")
                .uppercased()
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let r = (rgbValue & 0xFF0000) >> 16
        let g = (rgbValue & 0xFF00) >> 8
        let b = rgbValue & 0xFF
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
    public convenience init(r: Int, g: Int, b: Int, _ alpha: CGFloat = 1.0) {
        assert(r >= 0 && r <= 255, "Invalid Red component")
        assert(g >= 0 && g <= 255, "Invalid Green component")
        assert(b >= 0 && b <= 255, "Invalid Blue component")
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
    }
}
