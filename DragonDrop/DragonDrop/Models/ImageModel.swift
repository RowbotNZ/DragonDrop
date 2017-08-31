//
//  ImageModel.swift
//  DragonDrop
//
//  Created by Rowan on 20/08/17.
//  Copyright © 2017 Rowan Livingstone. All rights reserved.
//

import Foundation
import UIKit

struct ImageModel: DisplayItemConvertible {
    var image: UIImage
    
    var displayItem: DisplayItem {
        return .image(image)
    }
}

extension ImageModel: Draggable {
    var dragItem: UIDragItem {
        let itemProvider = NSItemProvider(object: image)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = self
        return dragItem
    }
}
