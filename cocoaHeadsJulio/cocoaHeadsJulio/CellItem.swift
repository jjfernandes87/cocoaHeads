//
//  CellItem.swift
//  cocoaHeadsJulio
//
//  Created by Julio Fernandes on 24/02/16.
//  Copyright © 2016 Julio Fernandes. All rights reserved.
//

import UIKit

class CellItem: NSObject {
    
    private(set) var cellIdentifier: String?
    private(set) var shortcutIcon: String?
    private(set) var title: String?
    private(set) var placeholder: String?
    
    func converterClassToCell() -> BaseCell {
        var instance: BaseCell! = nil
        if let classInst = NSClassFromString(cellIdentifier!) as? BaseCell.Type {
            instance = classInst.init(cellMenuItem: self)
        }
        
        return instance
    }
    
    init(model: NSDictionary) {
        super.init()
        
        if let string = model["CellIdentifier"] as? String {
            cellIdentifier = string
        }
        
        if let string = model["ShortcutIcon"] as? String {
            shortcutIcon = string
        }
        
        if let dict = model["UserInfo"] as? NSDictionary {
            if let string = dict["Title"] as? String {
                title = string
            }
            
            if let string = dict["PlaceHolder"] as? String {
                placeholder = string
            }
        }
    }
}