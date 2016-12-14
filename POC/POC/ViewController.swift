//
//  ViewController.swift
//  POC
//
//  Created by Umar Farooque on 06/12/16.
//  Copyright © 2016 temp. All rights reserved.
//

import UIKit

//class ViewController: UIViewController {
//
//    var oauthswift: OAuthSwift?
//    var currentParameters = [String: String]()
//
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view, typically from a nib.
//        self.doOAuthFlickr(["consumerKey":"72048efe61d5bb85ac1e5199e6aaf8ad","consumerSecret":"cc2af081d92e37f6"])
//
//    }
//    
//    
//    func doOAuthFlickr(_ serviceParameters: [String:String]){
//        let oauthswift = OAuth1Swift(
//            consumerKey:    serviceParameters["consumerKey"]!,
//            consumerSecret: serviceParameters["consumerSecret"]!,
//            requestTokenUrl: "https://www.flickr.com/services/oauth/request_token",
//            authorizeUrl:    "https://www.flickr.com/services/oauth/authorize",
//            accessTokenUrl:  "https://www.flickr.com/services/oauth/access_token"
//        )
//        self.oauthswift = oauthswift
//        oauthswift.authorizeURLHandler = SafariURLHandler(viewController: self, oauthSwift: oauthswift)
//        let _ = oauthswift.authorize(
//            withCallbackURL: URL(string: "POC://oauth-callback/flickr")!,
//            success: { credential, response, parameters in
//                self.showTokenAlert(name: "Flickr", credential: credential)
//                self.testFlickr(oauthswift, consumerKey: serviceParameters["consumerKey"]!)
//        },
//            failure: { error in
//                print(error.description)
//        }
//        )
//    }
//    func testFlickr (_ oauthswift: OAuth1Swift, consumerKey: String) {
//        let url :String = "https://api.flickr.com/services/rest/"
//        let parameters :Dictionary = [
//            "method"         : "flickr.photos.search",
//            "api_key"        : consumerKey,
//            "user_id"        : "128483205@N08",
//            "format"         : "json",
//            "nojsoncallback" : "1",
//            "extras"         : "url_q,url_z"
//        ]
//        let _ = oauthswift.client.get(
//            url, parameters: parameters,
//            success: { response in
//                let jsonDict = try? response.jsonObject()
//                print(jsonDict as Any)
//        },
//            failure: { error in
//                print(error)
//        }
//        )
//    }
//    
//    
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    
//    func showTokenAlert(name: String?, credential: OAuthSwiftCredential) {
//        var message = "oauth_token:\(credential.oauthToken)"
//        if !credential.oauthTokenSecret.isEmpty {
//            message += "\n\noauth_token_secret:\(credential.oauthTokenSecret)"
//        }
//        self.showAlertView(title: name ?? "Service", message: message)
//        
//    }
//    
//
//    func showAlertView(title: String, message: String) {
//
//        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
//            alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//        
//        }
//    
//}




