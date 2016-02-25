//
//  BaseCell.swift
//  cocoaHeadsJulio
//
//  Created by Julio Fernandes on 24/02/16.
//  Copyright © 2016 Julio Fernandes. All rights reserved.
//

import UIKit

@objc(BaseCell)
class BaseCell: SCTCellController {
    private(set) var cellItem: CellItem
    
    deinit {
        print(NSStringFromClass(BaseCell.self))
    }
    
    required init(cellMenuItem: CellItem) {
        cellItem = cellMenuItem
        super.init()
    }
}

class BaseCellView: SCTCellView {
    
}

struct StyleCell {
    var defaultColor = UIColor.lightGrayColor()
    var selectedColor = UIColor.lightGrayColor()
    var erroColor = UIColor.redColor()
    var concludeColor = UIColor.greenColor()
    var imageDone = UIImage(named: "ico_checkOK")
    var imagewarning = UIImage(named: "ic_alerta")
}

@objc(BaseStateCell)
class BaseStateCell: BaseCell {
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = loadDefaultCellForTable(tableView, atIndexPath: indexPath) as! BaseStateCellView
        cell.title.text = cellItem.title
        cell.defaultStyle()
        
        return cell
    }
}

class BaseStateCellView: BaseCellView {
    let style = StyleCell()
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var imageViewState: UIImageView!
    @IBOutlet weak var leftMargin: NSLayoutConstraint!
    
    func defaultStyle() {
        if let icon = imageViewState {
            icon.layer.borderColor = style.defaultColor.CGColor
            setIconDefault()
            defaultValue()
        }
    }
    
    func selectedStyle() {
        if let icon = imageViewState {
            icon.layer.borderColor = style.selectedColor.CGColor
            setIconDefault()
            defaultValue()
        }
    }
    
    func concludeStyle() {
        if let icon = imageViewState {
            defaultValue()
            setIconDone()
            icon.layer.borderColor =  style.concludeColor.CGColor
        }
    }
    
    func warningStyle() {
        if let icon = imageViewState {
            defaultValue()
            icon.layer.borderColor = style.erroColor.CGColor
            setIconWarning()
        }
    }
    
    func setIconDefault() {
        if (controller as! BaseStateCell).cellItem.shortcutIcon != nil {
            let iconName = (controller as! BaseStateCell).cellItem.shortcutIcon!
            
            if iconName != "" {
                imageViewState.image = UIImage(named: iconName)
                imageViewState.hidden = false
            } else {
                imageViewState.hidden = true
            }
            
            adjustMargin(iconName == "" ? true : false)
        } else {
            imageViewState.hidden = true
            adjustMargin(true)
        }
    }
    
    func setIconDone() {
        if let icon = imageViewState {
            icon.image = style.imageDone
        }
    }
    
    func setIconWarning() {
        if let icon = imageViewState {
            icon.image = style.imagewarning
        }
    }
    
    func defaultValue() {
        if let icon = imageViewState {
            icon.layer.cornerRadius = 3
            icon.layer.borderWidth = 1
        }
    }
    
    func adjustMargin(adjust: Bool) {
        if let left = leftMargin {
            left.constant = adjust ? 7 : 47
        }
    }
}