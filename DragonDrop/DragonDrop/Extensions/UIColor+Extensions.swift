//
//  UIColor+Extensions.swift
//  DragonDrop
//
//  Created by Rowan on 23/08/17.
//  Copyright © 2017 Rowan Livingstone. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    /// Initialises a `UIColor` instance from four `UInt8` values representing the
    /// hexadecimal RGBA values of the desired color.
    ///
    /// - Parameters:
    ///     - red: The red component of the desired color.
    ///     - green: The green component of the desired color.
    ///     - blue: The blue component of the desired color.
    ///     - alpha: The desired alpha value.
    convenience init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
        self.init(
            red: CGFloat(CGFloat(red) / CGFloat(UInt8.max)),
            green: CGFloat(CGFloat(green) / CGFloat(UInt8.max)),
            blue: CGFloat(CGFloat(blue) / CGFloat(UInt8.max)),
            alpha: CGFloat(CGFloat(alpha) / CGFloat(UInt8.max))
        )
    }
    
    /// Initialises a `UIColor` instance from a `UInt32` value representing the
    /// four pairs of hexadecimal digits (e.g `0xFFFFFFFF` is opaque white) that give
    /// the desired RGBA values.
    ///
    /// - Parameter rgba: The 32 bit unsigned integer describing the desired color.
    convenience init(rgba: UInt32) {
        self.init(
            red: UInt8((rgba >> 24) & UInt32(UInt8.max)),
            green: UInt8((rgba >> 16) & UInt32(UInt8.max)),
            blue: UInt8((rgba >> 8) & UInt32(UInt8.max)),
            alpha: UInt8(rgba & UInt32(UInt8.max))
        )
    }
    
    var rgba: UInt32 {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        guard getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return 0
        }
        
        return [red, green, blue, alpha].reduce(0, { (result, next) -> UInt32 in
            return (result << 8) | UInt32(next * CGFloat(UInt8.max))
        })
    }

    func adjusted(withLightnessFactor lightnessFactor: CGFloat) -> UIColor? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        guard getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }
        
        red *= lightnessFactor
        green *= lightnessFactor
        blue *= lightnessFactor
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
}
