//
//  LogoutViewController.swift
//  POC
//
//  Created by Umar Farooque on 08/12/16.
//  Copyright © 2016 temp. All rights reserved.
//

import UIKit
import FlickrKitFramework


class LogoutViewController: UIViewController {
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userProfileURLLabel: UILabel!
    @IBOutlet weak var userIDLabel: UILabel!
    
    
    //MARK: VIEW LIFE CYCLE
    override func viewDidLoad() {
        
        showIndicator(currentView: self.view)
        super.viewDidLoad()
        //call userinfo
        FlickrKit.shared().call("flickr.people.getInfo", args: ["user_id":userID,"format":"json","nojsoncallback":"1"]) { (respDict, error) in
            if error == nil {
                if respDict != nil {
                    DispatchQueue.main.async(execute: { () -> Void in

                        self.userIDLabel.text = userID
                        self.userNameLabel.text = (((respDict!["person"] as! [String:Any])["username"]) as! [String:Any])["_content"] as? String ?? "Username"
                        self.userProfileURLLabel.text = (((respDict!["person"] as! [String:Any])["profileurl"]) as! [String:Any])["_content"] as? String ?? "ProfileURL"
                        self.removeIndicator(currentView: self.view)
                    })
                }
                
            }else{
                
                let alertController = UIAlertController(title: "Error", message: error.debugDescription, preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "OK", style: .default, handler: {
                    (action : UIAlertAction!) -> Void in
                })
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
                self.removeIndicator(currentView: self.view)
                self.removeIndicator(currentView: self.view)

            }
        }
    }
    
    //MARK: LOGOUT ACTION
    @IBAction func logoutButtonAction(_ sender: Any) {
        
        userAuthSecret = ""
        userID = ""
        userAuthToken = ""
        FlickrKit.shared().logout()
        UserDefaults.standard.removeObject(forKey: userIDTag)
        UserDefaults.standard.removeObject(forKey: userAuthSecretTAG)
        UserDefaults.standard.removeObject(forKey: userAuthTokenTAG)
        UserDefaults.standard.synchronize()
        //present login on public feed
        self.tabBarController?.selectedIndex = 0
    }
    
}
