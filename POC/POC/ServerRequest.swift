//
//  ServerRequest.swift
//  POC
//
//  Created by Umar Farooque on 06/12/16.
//  Copyright © 2016 temp. All rights reserved.
//

import UIKit
import Foundation

//A custom server request class that can be used for handling server calls.
// MARK: The ServerRequestDelegate protocol & methods

protocol ServerRequestDelegate : class {
    
    func requestFinishedWithResult(_ responseDictionary :[String:Any],apiCallType: ServerRequest.API_TYPES_NAME,response:URLResponse)->Void
    func requestFinishedWithResultArray(_ responseArray :Array<Any>,apiCallType: ServerRequest.API_TYPES_NAME,response:URLResponse)->Void
    func requestFinishedWithResponse(_ response: URLResponse, message:String ,apiCallType:ServerRequest.API_TYPES_NAME)-> Void
    func requestFailedWithError(_ error: Error ,apiCallType:ServerRequest.API_TYPES_NAME,response:URLResponse?) ->Void
    
}

class ServerRequest: NSObject{
    
    // MARK: - API TYPES
    var apiType: API_TYPES_NAME?
    
    enum API_TYPES_NAME: Int {
        case publicFeedAPI
        case imageUploadAPI
        case myImageAPI
        case logoutAPI
    }
    
    
    //MARK:  Variables
    weak var delegate: ServerRequestDelegate?
    //MARK: Functions for server interactions
    func generateUrlRequestWithURLPartParameters(_ urlPartParam:[String:Any]?, postParam:[String:Any]?)-> Void {
        
        var serverRequestUrl:String
        let request = NSMutableURLRequest()
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 25.0
        if postParam != nil
        {
            do{
                let httpBodyData = try JSONSerialization.data(withJSONObject: postParam!, options: JSONSerialization.WritingOptions())
                request.httpBody = httpBodyData
            }
            catch let error as NSError {
                // SHOW ERROR
                DispatchQueue.main.async(execute: {
                    self.delegate?.requestFailedWithError(error, apiCallType: self.apiType!,response: nil)
                })
                return
            }
        }
        var urlStr: String = ""
        switch apiType! {
            
        case .publicFeedAPI:
            
            urlStr = "https://api.flickr.com/services/rest/?method=flickr.interestingness.getList&format=json&per_page=20&api_key=\(userKey)&nojsoncallback=1&page=\(urlPartParam?["pageCounter"] as! Int)"
            request.httpMethod="GET"
            
        default :
            
            urlStr = ""
        }
        
        serverRequestUrl = "\(urlStr)"
        serverRequestUrl = serverRequestUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        request.url = URL(string:serverRequestUrl)
        self.performSessionDataTaskwithRequest(request as URLRequest)
    }
    
    // MARK: - Used for pagination
    func generateUrlRequestWithURLString(_ urlString:String )->Void{
        
        let request = NSMutableURLRequest()
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 25.0
        request.httpMethod = "GET"
        request.url = URL(string: urlString)
        self.performSessionDataTaskwithRequest(request as URLRequest)
    }
    
    
    // MARK: - Process Request
    public func performSessionDataTaskwithRequest(_ request:URLRequest)->Void{
        var resultFromServer: Any?
        var responseResultData = [String:Any]()
        var responseResultArr = Array<Any>()
        
        //configure session
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        let session : URLSession
        session = URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
        //nil check to handle the case when the next page url hit, in that case api type isnt set or required as we get the raw URL
        session.dataTask(with: request) { (data, response, error ) in
            if error != nil {
                DispatchQueue.main.async(execute: {
                    self.delegate?.requestFailedWithError(error!, apiCallType: self.apiType!,response: nil)
                    session.invalidateAndCancel()
                })
                
            }else{
                
                let httpResponse: HTTPURLResponse = response as! HTTPURLResponse
                do{
                    resultFromServer = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                    if httpResponse.statusCode == 200  || httpResponse.statusCode == 201 || httpResponse.statusCode == 202 || httpResponse.statusCode == 204 || httpResponse.statusCode == 203{
                        if let respArr = resultFromServer as? [Any]{
                            responseResultArr = respArr
                            //arr
                            DispatchQueue.main.async(execute: {
                                self.delegate?.requestFinishedWithResultArray(responseResultArr, apiCallType: self.apiType!,response: httpResponse)
                            })
                            
                        }else if let respdict = resultFromServer as? [String : Any] {
                            
                            responseResultData = respdict
                            //dict
                            DispatchQueue.main.async(execute: {
                                self.delegate?.requestFinishedWithResult(responseResultData,apiCallType: self.apiType!,response: httpResponse)
                            })
                            
                        }else{
                            
                            DispatchQueue.main.async(execute: {
                                self.delegate?.requestFinishedWithResult(responseResultData,apiCallType: self.apiType!,response: httpResponse)
                            })
                        }
                    }
                    else {
                        
                        if httpResponse.statusCode == 401  || httpResponse.statusCode == 403 || httpResponse.statusCode == 402 || httpResponse.statusCode == 404  {
                            if let respdict = resultFromServer as? [Any] {
                                DispatchQueue.main.async(execute: {
                                    self.delegate?.requestFinishedWithResultArray(respdict, apiCallType: self.apiType!,response: httpResponse)
                                })
                            }
                            
                            if let respdict = resultFromServer as? [String : Any] {
                                DispatchQueue.main.async(execute: {
                                    self.delegate?.requestFinishedWithResult(respdict, apiCallType: self.apiType!, response: httpResponse)
                                })
                            }
                        }
                    }
                }
                catch let error as NSError {
                    
                    DispatchQueue.main.async(execute: {
                        self.delegate?.requestFailedWithError(error, apiCallType: self.apiType!,response:httpResponse)
                        session.invalidateAndCancel()
                    })
                }
                
            }
            session.finishTasksAndInvalidate()
            }.resume()
    }
}



