//
//  ImageObject.swift
//  POC
//
//  Created by Umar Farooque on 06/12/16.
//  Copyright © 2016 temp. All rights reserved.
//

import UIKit


class ImageObject: NSObject {

    var farm = ""
    var secret = ""
    var server = ""
    var id = ""
    var title = ""
    
    
    
    //MARK: OBJECT INIT
    init(imgDict:[String:Any]) {
        
        self.farm = "\(imgDict["farm"] as! Int)"
        self.secret = imgDict["secret"] as! String
        self.server = imgDict["server"] as! String
        self.id = imgDict["id"] as! String
        self.title = imgDict["title"] as! String
        super.init()
        
    }
    
}
