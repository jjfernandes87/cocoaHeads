//
//  ViewController.swift
//  cocoaHeadsJulio
//
//  Created by Julio Fernandes on 24/02/16.
//  Copyright © 2016 Julio Fernandes. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: SelfContainedTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCells()
    }

    func loadCells() {
        var sectionAndRows = [AnyObject]()
        guard let path = openFile("anuncie", type: "plist") else {
            return NSException(name: "StepController Error:", reason: "Unable To Load", userInfo: nil).raise()
        }

        guard let sectionList = NSArray(contentsOfFile: path) else {
            return NSException(name: "StepController Error:", reason: "Type Not Found", userInfo: nil).raise()
        }
        
        for (_, response) in sectionList.enumerate() {
            
            guard let section = response as? NSDictionary else {
                return
            }
            
            guard let rows = section["Rows"] as? NSArray where rows.count > 0 else {
                continue
            }
            
            if let title = section["Section"] as? String, let details = section["Details"] as? String {
                sectionAndRows.append(HeaderDetailsController.initWithTitle(title, details: details))
            } else if let title = section["Section"] as? String {
                sectionAndRows.append(HeaderController.initWithTitle(title))
            }
            
            for (_, response) in rows.enumerate() {
                if let row = response as? NSDictionary {
                    if let model:CellItem = CellItem(model: row) {
                        let cell = model.converterClassToCell()
                        sectionAndRows.append(cell)
                    }
                }
            }
        }
        
        tableView.setSectionsAndRows(sectionAndRows, reload: true)
    }
    
    func openFile(file: String, type: String) -> String? {
        
        guard let path = NSBundle.mainBundle().pathForResource(file, ofType: type) else {
            return nil
        }
        
        return path
    }

}

