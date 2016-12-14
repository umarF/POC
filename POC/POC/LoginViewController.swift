//
//  LoginViewController.swift
//  POC
//
//  Created by Umar Farooque on 06/12/16.
//  Copyright © 2016 temp. All rights reserved.
//

import UIKit
import SafariServices
import FlickrKitFramework

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.dissmissLogin), name: NSNotification.Name(rawValue: "dismissLogin"), object: nil)
    }
    
    //MARK: HELPER FUNCTIONS

    func dissmissLogin(){
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: BUTTON ACTIONS
    
    @IBAction func loginButtonAction(_ sender: Any) {
                
        //show loader
        showIndicator(currentView: self.view)
        if(FlickrKit.shared().isAuthorized) {
            FlickrKit.shared().logout()
        } else {
            //present webview controller
            let webLoginVC = storyboard?.instantiateViewController(withIdentifier: "weblogin") as! WebLoginController
            self.present(webLoginVC, animated: true, completion: {
            })
        }
        
    }
    
    
    @IBAction func closeButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
