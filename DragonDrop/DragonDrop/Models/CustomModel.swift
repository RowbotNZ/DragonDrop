//
//  CustomModel.swift
//  DragonDrop
//
//  Created by Rowan on 20/08/17.
//  Copyright © 2017 Rowan Livingstone. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices

class CustomModel: NSObject, DisplayItemConvertible, Codable {
    
    fileprivate static let customTypeIdentifier = "com.rowanlivingstone.dragondrop.custom"
    
    var customString1: String
    var customString2: String
    var customColor: UIColor
    
    enum CodingKeys: String, CodingKey {
        case customString1
        case customString2
        case customColor
    }
    
    var displayItem: DisplayItem {
        return .plain(title: customString1, detail: customString2, color: customColor)
    }
    
    init(customString1: String, customString2: String, customColor: UIColor) {
        self.customString1 = customString1
        self.customString2 = customString2
        self.customColor = customColor
        
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        customString1 = try values.decode(String.self, forKey: .customString1)
        customString2 = try values.decode(String.self, forKey: .customString2)
        customColor = try UIColor(rgba: values.decode(UInt32.self, forKey: .customColor))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(customString1, forKey: .customString1)
        try container.encode(customString2, forKey: .customString2)        
        try container.encode(customColor.rgba, forKey: .customColor)
    }
    
}

extension CustomModel: Draggable {
    
    var dragItem: UIDragItem {
        let itemProvider = NSItemProvider(object: self)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = self
        return dragItem
    }
    
}

extension CustomModel: NSItemProviderWriting {
    
    static var writableTypeIdentifiersForItemProvider: [String] {
        return [customTypeIdentifier, String(kUTTypeUTF8PlainText)]
    }
    
    func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        var fetchBlock: () -> ()
        switch typeIdentifier {
        case CustomModel.customTypeIdentifier:
            fetchBlock = {
                let encoder = JSONEncoder()
                do {
                    let data = try encoder.encode(self)
                    completionHandler(data, nil)
                }
                catch {
                    completionHandler(nil, error)
                }
            }
        case String(kUTTypeUTF8PlainText):
            fetchBlock = {
                completionHandler(self.customString1.data(using: String.Encoding.utf8), nil)
            }
        default:
            return nil
        }
        
        let progress = Progress(totalUnitCount: 100)
        
        let queue = DispatchQueue.global()
        let workItem = DispatchWorkItem(block: fetchBlock)
        
        progress.cancellationHandler = {
            workItem.cancel()
        }
        
        queue.async(execute: workItem)

        return progress
    }

}

extension CustomModel: NSItemProviderReading {
    
    static var readableTypeIdentifiersForItemProvider: [String] {
        return [customTypeIdentifier]
    }
    
    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Self {
        let decoder = JSONDecoder()
        return try decoder.decode(self, from: data)
    }
    
}
