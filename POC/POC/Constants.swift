//
//  Constants.swift
//  POC
//
//  Created by Umar Farooque on 06/12/16.
//  Copyright © 2016 temp. All rights reserved.
//

import UIKit
import FlickrKitFramework

//KEYS AND VARIABLES
let userKey = "" //your flickr user key
let userSecret = "" // your flickr user secret
var userAuthToken = ""
var userAuthSecret = ""
var imageCache:NSCache = NSCache<AnyObject,AnyObject>()
var userID = ""
var forceReload = 0
var retryUpload = 0


//TAGS
var userIDTag = "userIDTag"
var userAuthTokenTAG = "userAuthTokenTAG"
var userAuthSecretTAG = "userAuthSecretTAG"



// GLOBAL functions for showing indicator and downloading images

extension UIViewController {
    
    //MARK: INDICATOR
    func showIndicator(currentView:UIView){
        
        let container: UIView = UIView()
        container.frame = currentView.frame
        container.center = currentView.center
        container.backgroundColor = UIColor.white
        let loadingView: UIView = UIView()
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = currentView.center
        loadingView.backgroundColor = UIColor.black
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
        actInd.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        actInd.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.whiteLarge
        actInd.center = CGPoint(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2)
        loadingView.addSubview(actInd)
        container.addSubview(loadingView)
        currentView.addSubview(container)
        container.tag = 999
        actInd.startAnimating()
        
    }
    
    func removeIndicator(currentView:UIView){
        currentView.viewWithTag(999)?.removeFromSuperview()
    }
    
    //MARK: GENERATE URL
    func generateDownloadURL(obj:ImageObject) -> String {
        let urlString = "https://farm\(obj.farm).staticflickr.com/\(obj.server)/\(obj.id)_\(obj.secret)_n.jpg"
        return urlString
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    
    //MARK: DOWNLOAD IMAGE FUNCTIONS
    func downloadImagefromURL(stringURL:String, imageView: UIImageView,completion: @escaping ((_ data: NSData?, _ response: URLResponse?, _ error: NSError? ) -> Void))
    {
        var request = URLRequest(url:URL(string: stringURL)!)
        request.timeoutInterval = 25.0
        request.httpMethod = "GET"
        //configure session
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringCacheData
        let session : URLSession
        session = URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
        DispatchQueue.global(qos: .background).async {
            session.dataTask(with: request) { (data, response, error) in
                if error != nil {
                    
                    //print("error \(error)")
                    
                }else {
                    if response != nil {
                        let httpResponse: HTTPURLResponse = response as! HTTPURLResponse
                        if (httpResponse.statusCode == 200 || httpResponse.statusCode == 201 || httpResponse.statusCode == 204 || httpResponse.statusCode == 203)
                        {
                             if data != nil {
                                DispatchQueue.main.async(execute: {
                                    completion(data as NSData?, response, error as NSError?)
                                })
                           }
                            
                        } else if httpResponse.statusCode == 400 || httpResponse.statusCode == 401  ||
                            httpResponse.statusCode == 402 || httpResponse.statusCode == 403 || httpResponse.statusCode == 404 || httpResponse.statusCode == 405 || httpResponse.statusCode == 406 {
                            //failure
                        }
                    }
                }
            }.resume()
        }
    }
    
}
