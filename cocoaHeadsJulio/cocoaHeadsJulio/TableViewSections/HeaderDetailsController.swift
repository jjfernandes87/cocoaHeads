//
//  HeaderDetailsController.swift
//  AnuncieSDK
//
//  Created by Julio Fernandes Junior on 11/01/16.
//  Copyright © 2016 Zap Imóveis. All rights reserved.
//

import UIKit

@objc(HeaderDetailsController)
class HeaderDetailsController: SCTSectionController {
    var title: String?
    var details: String?
    
    class func initWithTitle(title: String, details: String) -> HeaderDetailsController {
        let controller = HeaderDetailsController()
        controller.title = title
        controller.details = details
        
        return controller
    }
    
    deinit {
        title = nil
    }
    
    override func tableView(tableView: UITableView!, heightForHeaderInSection section: Int) -> CGFloat {
        let titleHeight = calculateContentHeight(title!, width: UIScreen.mainScreen().bounds.size.width)
        let detailsHeight = calculateContentHeight(details!, width: UIScreen.mainScreen().bounds.size.width)
        
        return 25 + titleHeight + detailsHeight
    }
    
    override func tableView(tableView: UITableView!, viewForHeaderInSection section: Int) -> UIView! {
        let header = loadDefaultHeaderForTableView(tableView, viewForHeaderInSection: section) as! HeaderDetailsControllerView
        header.title.text = title?.uppercaseString
        header.subTitle.text = details
        
        return header
    }
    
    func calculateContentHeight(text: String, width: CGFloat) -> CGFloat {
        let maxLabelSize: CGSize = CGSizeMake(width - 30, CGFloat(9999))
        let contentNSString = text as NSString
        let expectedLabelSize = contentNSString.boundingRectWithSize(maxLabelSize, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(10.0)], context: nil)
        
        return expectedLabelSize.size.height
    }
}

class HeaderDetailsControllerView: SCTSectionView {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    
    deinit {
        title = nil
        subTitle = nil
    }
}