//
//  SimpleModel.swift
//  DragonDrop
//
//  Created by Rowan on 20/08/17.
//  Copyright © 2017 Rowan Livingstone. All rights reserved.
//

import Foundation
import UIKit

struct SimpleModel: DisplayItemConvertible {
    var title: String
    var detail: String
    var color: UIColor
    
    var displayItem: DisplayItem {
        return .plain(title: title, detail: detail, color: color)
    }
}

extension SimpleModel: Draggable {
    var dragItem: UIDragItem {
        let itemProvider = NSItemProvider(object: "\(title), \(detail)" as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = self
        return dragItem
    }
}
