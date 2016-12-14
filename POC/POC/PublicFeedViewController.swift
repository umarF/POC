//
//  PublicFeedViewController.swift
//  POC
//
//  Created by Umar Farooque on 06/12/16.
//  Copyright © 2016 temp. All rights reserved.
//

import UIKit
import FlickrKitFramework

class PublicFeedViewController: UIViewController {
    
    var imgArray = [ImageObject]()
    var completeAuthOp: FKDUNetworkOperation!
    var checkAuthOp: FKDUNetworkOperation!

    //MARK: VIEW LIFE CYCLES
    override func viewDidLoad() {
        super.viewDidLoad()
        self.checkAuthentication()
    }

    //MARK: FLICKR AUTH HELPER FUNCTION
    
    func checkAuthentication() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "UserAuthCallbackNotification"), object: nil, queue: OperationQueue.main) { (notification) -> Void in
            let callBackURL: URL = notification.object as! URL
            self.completeAuthOp = FlickrKit.shared().completeAuth(with: callBackURL, completion: { (userName, userId, fullName, error) -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    if ((error == nil)) {
                        
                        //SAVE TOKENS AND CHECK FOR SESSION
                        userID = userId!
                        userAuthToken = FlickrKit.shared().authToken!
                        userAuthSecret = FlickrKit.shared().authSecret!
                        UserDefaults.standard.setValue(userId, forKey: userIDTag)
                        UserDefaults.standard.setValue(FlickrKit.shared().authToken, forKey: userAuthTokenTAG)
                        UserDefaults.standard.setValue(FlickrKit.shared().authSecret, forKey: userAuthSecretTAG)
                        UserDefaults.standard.synchronize()
                        
                    } else {
                        let alertController = UIAlertController(title: "Error", message: "Encountered Error", preferredStyle: .alert)
                        let cancelAction = UIAlertAction(title: "OK", style: .default, handler: {
                            (action : UIAlertAction!) -> Void in
                        })
                        alertController.addAction(cancelAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                    
                    //dismiss login
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dismissWebLogin"), object: nil)
                });
            })
        }

    }
    

    
}



