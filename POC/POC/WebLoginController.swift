//
//  WebLoginController.swift
//  POC
//
//  Created by Umar Farooque on 07/12/16.
//  Copyright © 2016 temp. All rights reserved.
//

import UIKit
import FlickrKitFramework



class WebLoginController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(WebLoginController.dissmissLogin), name: NSNotification.Name(rawValue: "dismissWebLogin"), object: nil)
    }
    //method to dissmiss weblogin
    func dissmissLogin(){
        
        self.dismiss(animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                //notif to dismiss login
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dismissLogin"), object: nil)
            }
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {

        showIndicator(currentView: self.view)
        let callbackURLString = "flickrkitdemo://auth"
        // Begin the authentication process
        let url = URL(string: callbackURLString)
        FlickrKit.shared().beginAuth(withCallbackURL: url!, permission: FKPermission.delete, completion: { (url, error) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                if ((error == nil)) {
                    let urlRequest = NSMutableURLRequest(url: url!, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 30)
                    self.webView.loadRequest(urlRequest as URLRequest)
                } else {
                    retryUpload = 0
                    self.removeIndicator(currentView: self.view)
                    let alertController = UIAlertController(title: "Retry", message: "Try to upload again.", preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "OK", style: .default, handler: {
                        (action : UIAlertAction!) -> Void in
                        DispatchQueue.main.async(execute: { () -> Void in
                            self.dissmissLogin()
                        })

                    })
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            });
        })
    }
    
    // MARK: WebViewDelegate
    
    func webView(_ webView: UIWebView, shouldStartLoadWithRequest request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let url = request.url
        removeIndicator(currentView: self.view)
        if  !(url?.scheme == "http") && !(url?.scheme == "https") {
            if (UIApplication.shared.canOpenURL(url!)) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url!, options: ["":""], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                    UIApplication.shared.openURL(url!)

                }
                return false
            }
        }
        return true
        
    }
    //Button Action
    @IBAction func closeButtonAction(_ sender: Any) {
        self.dissmissLogin()
    }
}
