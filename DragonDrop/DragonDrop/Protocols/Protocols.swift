//
//  Protocols.swift
//  DragonDrop
//
//  Created by Rowan on 20/08/17.
//  Copyright © 2017 Rowan Livingstone. All rights reserved.
//

import Foundation
import UIKit

enum DisplayItem: Equatable {
    case placeholder
    case plain(title: String, detail: String, color: UIColor)
    case image(UIImage)
    
    static func ==(lhs: DisplayItem, rhs: DisplayItem) -> Bool {
        switch (lhs, rhs) {
        case (.placeholder, .placeholder):
            return true
        case (.plain(let lhsTitle, let lhsDetail, let lhsColor), .plain(let rhsTitle, let rhsDetail, let rhsColor)):
            return lhsTitle == rhsTitle && lhsDetail == rhsDetail && lhsColor.cgColor == rhsColor.cgColor
        case (.image(let lhsImage), .image(let rhsImage)):
            return UIImagePNGRepresentation(lhsImage) == UIImagePNGRepresentation(rhsImage)
        default:
            return false
        }
    }
}

protocol DisplayItemConvertible {
    var displayItem: DisplayItem { get }
}

extension DisplayItemConvertible {
    var displayItem: DisplayItem {
        return .placeholder
    }
}

protocol Draggable {
    var dragItem: UIDragItem { get }
}
