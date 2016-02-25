//
//  Header.swift
//  SlideMenu
//
//  Created by Julio Fernandes Junior on 27/11/15.
//  Copyright © 2015 Julio Fernandes Junior. All rights reserved.
//

import UIKit

@objc(HeaderController)
class HeaderController: SCTSectionController {
    var title: String?
    
    class func initWithTitle(title: String) -> HeaderController {
        let controller = HeaderController()
        controller.title = title
        
        return controller
    }
    
    deinit {
        title = nil
    }
    
    override func tableView(tableView: UITableView!, heightForHeaderInSection section: Int) -> CGFloat {
        return title?.characters.count > 0 ? 30 : 0
    }
    
    override func tableView(tableView: UITableView!, viewForHeaderInSection section: Int) -> UIView! {
        let header = loadDefaultHeaderForTableView(tableView, viewForHeaderInSection: section) as! HeaderView
        header.title.text = title?.uppercaseString
        
        return header
    }
}

class HeaderView: SCTSectionView {
    @IBOutlet weak var title: UILabel!
    
    deinit {
        title = nil
    }
}