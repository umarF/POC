//
//  CommonCollectionViewController.swift
//  POC
//
//  Created by Umar Farooque on 09/12/16.
//  Copyright © 2016 temp. All rights reserved.


//THIS CLASS IS RESPONSIBLE FOR LOADING IMAGES IN COLLECTION VIEW IN BOTH FEED VIEW AND MY PICS

//

import UIKit
import FlickrKitFramework


class CommonCollectionViewController: UICollectionViewController {
    
    //MARK: VARIABLES
    var imgArray = [ImageObject]()
    var callType = 0
    let collectionCellIdentifier = "collectionCell2"
    let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    let itemsPerRow: CGFloat = 3
    var pageCounter = 0
    
    
    //MARK: VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        self.collectionView?.collectionViewLayout = UICollectionViewFlowLayout()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        //MARK: CHECK FOR TOKENS
        if userAuthSecret.characters.count == 0 || userAuthToken.characters.count == 0 {
            //present login
            let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginVC" ) as! LoginViewController
            self.navigationController?.present(loginVC, animated: true, completion: {
            })
            
        }else {
            
            if (self.parent)!.isKind(of: MyPicsViewController.self){
                self.callType = 1
                
            }else if (self.parent)!.isKind(of: PublicFeedViewController.self){
                self.callType = 0
            }
            if imgArray.count == 0 || forceReload == 1 {
                forceReload = 0
                imgArray.removeAll()
                self.collectionView?.reloadData()
                loadImagesFromFlickr()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        imageCache.removeAllObjects()
    }

    
    //MARK: LOAD IMAGES FROM API/BACKEND
    func loadImagesFromFlickr(){
        if imgArray.count == 0 {
            //show indicator for only when count ==0
            showIndicator(currentView: self.view)
        }
        //FOR PUBLIC IMAGES
        if callType == 0 {
            pageCounter = pageCounter + 1
            let serverRequestObj = ServerRequest()
            serverRequestObj.delegate = self
            serverRequestObj.apiType = ServerRequest.API_TYPES_NAME.publicFeedAPI
            serverRequestObj.generateUrlRequestWithURLPartParameters(["pageCounter":pageCounter], postParam: nil)
            
        }else if callType == 1 {
            //FOR UPLOADED PICS
            FlickrKit.shared().call("flickr.people.getPhotos", args: ["user_id":userID,"per_page": "500","format":"json","nojsoncallback":"1"], maxCacheAge: .infinite) { (respDict, error) in
                
                if error == nil {
                    if respDict != nil {
//                        print("RESP : \(respDict)")
                        let respArray = ((((respDict!["photos"] as? [String:Any]) )!["photo"]) as! [Any])
                        for obj in respArray {
                            let imageObj = ImageObject(imgDict: obj as! [String:Any])
                            self.imgArray.append(imageObj)
                        }
                        DispatchQueue.main.async(execute: {
                            self.removeIndicator(currentView: self.view)
                            self.collectionView?.reloadData()
                        })
                    }
                    
                }else{
                    print("ERRor : \(error.debugDescription)")
                }
            }
        }
    }
    
    
    //MARK: COLLECTION VIEW DELEGATE
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgArray.count
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionCellIdentifier,for: indexPath)
        let imageView = cell.viewWithTag(13) as! UIImageView
        DispatchQueue.main.async(execute: {
            imageView.image = UIImage(named: "placeholder")
        })
        //form the URL
        //check cache for URL key
        //load image in background and save in cache
        let imageDownloadString = generateDownloadURL(obj: imgArray[indexPath.row])
        if let imageDataPresent = imageCache.object(forKey: imageDownloadString as AnyObject) as? NSData {
            DispatchQueue.main.async(execute: {
                imageView.image = UIImage(data: imageDataPresent as Data)
            })
        }else {
            downloadImagefromURL(stringURL: imageDownloadString, imageView: imageView) { (data, response, error) in
                if error == nil {
                    if data != nil {
                        let celImage = UIImage(data: data! as Data)
                        if celImage != nil {
                            imageCache.setObject(data!, forKey: imageDownloadString as AnyObject)
                            DispatchQueue.main.async(execute: {
                                let currentCell = self.collectionView?.cellForItem(at: indexPath)
                                if currentCell == cell {
                                    imageView.image = celImage
                                }
                            })
                        }
                    }
                }
            }
            
        }
        
        if self.callType != 1 {
            if indexPath.row == imgArray.count - 3  {
                self.loadImagesFromFlickr()
            }
            
        }
        
        cell.backgroundColor = UIColor.black
        return cell
        
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //FULL SCREEN IMAGEVIEW
        let fullScreenImageVC = storyboard?.instantiateViewController(withIdentifier: "fullscreenImage") as! FullScreenImageViewController
        let imageDownloadString = generateDownloadURL(obj: imgArray[indexPath.row])
        if let imageDataPresent = imageCache.object(forKey: imageDownloadString as AnyObject) as? NSData {
            fullScreenImageVC.imageToDisplay = UIImage(data: imageDataPresent as Data)
        }else {
            if fullScreenImageVC.imageView != nil {
                downloadImagefromURL(stringURL: imageDownloadString, imageView: fullScreenImageVC.imageView) { (data, response, error) in
                    if error == nil {
                        if data != nil {
                            let celImage = UIImage(data: data! as Data)
                            if celImage != nil {
                                imageCache.setObject(data!, forKey: imageDownloadString as AnyObject)
                                DispatchQueue.main.async(execute: {
                                    fullScreenImageVC.imageToDisplay = celImage
                                })
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
                
            }
            
        }
        
        self.present(fullScreenImageVC, animated: true, completion: nil)
        
    }
    
}


//MARK: SERVER REQUEST DELEGATE

extension CommonCollectionViewController:ServerRequestDelegate{
    
    func requestFinishedWithResult(_ responseDictionary: [String : Any], apiCallType: ServerRequest.API_TYPES_NAME, response: URLResponse) {
        
        let resultArray = ((((responseDictionary )["photos"] as! [String:Any])["photo"] as! [Any]))
        if resultArray.count > 0 {
            for obj in resultArray {
                let imgObj = ImageObject(imgDict: (obj as! [String:Any]))
                imgArray.append(imgObj)
            }
            DispatchQueue.main.async(execute: {
                self.removeIndicator(currentView: self.view)
                self.collectionView?.reloadData()
            })
        }
    }
    
    
    func requestFinishedWithResultArray(_ responseArray: Array<Any>, apiCallType: ServerRequest.API_TYPES_NAME, response: URLResponse) {
        
        DispatchQueue.main.async(execute: {
            self.removeIndicator(currentView: self.view)
            self.collectionView?.reloadData()
        })
    }
    
    func requestFailedWithError(_ error: Error, apiCallType: ServerRequest.API_TYPES_NAME, response: URLResponse?) {
        
        DispatchQueue.main.async(execute: {
            self.removeIndicator(currentView: self.view)
            self.collectionView?.reloadData()
        })
    }
    
    
    func requestFinishedWithResponse(_ response: URLResponse, message: String, apiCallType: ServerRequest.API_TYPES_NAME) {
        
        DispatchQueue.main.async(execute: {
            self.removeIndicator(currentView: self.view)
            self.collectionView?.reloadData()
        })
    }
}


//MARK: COLLECTION VIEW FLOW DELEGATE
extension CommonCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    
    
}



