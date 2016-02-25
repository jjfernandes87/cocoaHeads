//
//  TextFieldCell.swift
//  cocoaHeadsJulio
//
//  Created by Julio Fernandes on 24/02/16.
//  Copyright © 2016 Julio Fernandes. All rights reserved.
//

import UIKit

@objc(TextFieldCell)
class TextFieldCell: BaseStateCell {
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath) as! TextFieldCellView
        cell.textField.placeholder = cellItem.placeholder
        cell.textField.inputAccessoryView = createKeyboardToolBar(cell)
        cell.textField.text!.characters.count > 0 ? cell.concludeStyle() : cell.defaultStyle()
        controllerCell = cell
        
        return cell
    }
    
    func createKeyboardToolBar(cell: TextFieldCellView) ->  UIToolbar {
        let toolbar = UIToolbar(frame: CGRectMake(0, 0, cell.contentView.frame.size.width, 44))
        let cancelBarButtonItem = UIBarButtonItem(title: "OK", style: UIBarButtonItemStyle.Done, target: self, action: "done")
        toolbar.setItems([cancelBarButtonItem], animated: false)
        
        return toolbar
    }
    
    func done() {
        if let cell = controllerCell as? TextFieldCellView {
            cell.textField.resignFirstResponder()
        }
    }
}

class TextFieldCellView: BaseStateCellView {
    @IBOutlet weak var textField: UITextField!
}