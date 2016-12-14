//
//  UploadImageViewController.swift
//  POC
//
//  Created by Umar Farooque on 06/12/16.
//  Copyright © 2016 temp. All rights reserved.
//

import UIKit
import MobileCoreServices
import FlickrKitFramework


class UploadImageViewController: UIViewController {
    
    var imagePicker = UIImagePickerController()
    @IBOutlet weak var imageTitle: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    var imageNameField: UITextField!
    var currentPhotoID = ""
    var currentPhotoObj = [String:Any]()
    var currentImageURL = ""
    
    
    //MARK: VIEW CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.removeIndicator(currentView: self.view)
        
        if retryUpload == 1 {
            
            retryUpload = 0
            let alertController = UIAlertController(title: "Upload", message: "Click upload to select image.", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .default, handler: {
                (action : UIAlertAction!) -> Void in
                
            })
            alertController.addAction(cancelAction)
            DispatchQueue.main.async(execute: {
                
                self.present(alertController, animated: true, completion: nil)
            })
            
        }
        
    }
    
    
    //MARK: BUTTON ACTION
    @IBAction func uploadButtonAction(_ sender: Any) {
        
        //image picker
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.mediaTypes = [kUTTypeImage as String]
        imagePicker.allowsEditing = true
        
        //show action sheet to choose camera or album
        let alertController = UIAlertController(title: "Choose", message: "Image Source", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (action : UIAlertAction!) -> Void in
        })
        alertController.addAction(cancelAction)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
            //show camera
            self.imagePicker.sourceType =  UIImagePickerControllerSourceType.camera
            self.present(self.imagePicker, animated: true,
                         completion: nil)
        })
        alertController.addAction(cameraAction)
        
        let albumAction = UIAlertAction(title: "Album", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
            //show album
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(self.imagePicker, animated: true,
                         completion: nil)
        })
        alertController.addAction(albumAction)
        self.present(alertController, animated: true, completion: nil)
    }
}



//MARK: UPLOAD - IMAGE PICKER DELEGATE
extension UploadImageViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        if mediaType.isEqual(to: kUTTypeImage as String) {
            //MAIN THREAD
            DispatchQueue.main.async(execute: {
                
                let image = info[UIImagePickerControllerOriginalImage] as! UIImage
                //ALERT CONTROLLER TO ENTER PICTURE NAME
                let alertController = UIAlertController(title: "Enter Picture Name", message: "", preferredStyle: .alert)
                alertController.addTextField { (textField : UITextField!) -> Void in
                    textField.text = ""
                    textField.placeholder = "Name"
                    self.imageNameField = textField
                }
                let saveAction = UIAlertAction(title: "Save", style: .default, handler: {
                    alert -> Void in
                    DispatchQueue.main.async(execute: {
                        self.showIndicator(currentView: self.view)
                    })
                    if self.imageNameField.text != nil {
                        
                        //ask alert for photo name
                        FlickrKit.shared().uploadImage(image, args: ["title":"\(self.imageNameField.text!) \(Date().description)"], completion: { (imageID, err) in
                            
                            if err != nil {
                                let alertController = UIAlertController(title: "Error - Login again", message: err?.localizedDescription, preferredStyle: .alert)
                                let cancelAction = UIAlertAction(title: "OK", style: .default, handler: {
                                    (action : UIAlertAction!) -> Void in
                                    if err.debugDescription.contains("Invalid signature"){
                                        DispatchQueue.main.async(execute: {
                                            //show loader
                                            self.showIndicator(currentView: self.view)
                                            //present webview controller
                                            retryUpload = 1
                                            let webLoginVC = self.storyboard?.instantiateViewController(withIdentifier: "weblogin") as! WebLoginController
                                            self.present(webLoginVC, animated: true, completion: {
                                            })
                                        })
                                    }
                                })
                                alertController.addAction(cancelAction)
                                DispatchQueue.main.async(execute: {
                                    self.present(alertController, animated: true, completion: nil)
                                    self.removeIndicator(currentView: self.view)
                                })
                                
                            }else{
                                
                                self.currentPhotoID = imageID!
                                print("Image ID \(imageID)")
                                FlickrKit.shared().call("flickr.people.getPhotos", args: ["user_id":userID,"per_page": "100","format":"json","nojsoncallback":"1"], maxCacheAge: .infinite) { (respDict, error) in
                                    if error == nil {
                                        if respDict != nil {
//                                            print("RESP : \(respDict)")
                                            let respArray = ((((respDict!["photos"] as? [String:Any]) )!["photo"]) as! [Any])
                                            for obj in respArray {
                                                if (obj as! [String:Any])["id"] as? String == self.currentPhotoID {
                                                    self.currentPhotoObj = obj as! [String:Any]
                                                }
                                                
                                            }
                                            
                                            if self.currentPhotoObj["id"] != nil {
                                                
                                                //forceReload
                                                forceReload = 1
                                                //load image URL
                                                self.currentImageURL = self.generateDownloadURL(obj: ImageObject(imgDict: self.currentPhotoObj))
                                                //if imageURL found, then load image and cache it
                                                if self.currentImageURL.characters.count > 3 {
                                                    self.downloadImagefromURL(stringURL: self.currentImageURL, imageView: self.imageView, completion: { (data, resp, error) in
                                                        if error == nil {
                                                            if data != nil {
                                                                let userImage = UIImage(data: data! as Data)
                                                                if userImage != nil {
                                                                    imageCache.setObject(data!, forKey: self.currentImageURL as AnyObject)
                                                                    DispatchQueue.main.async(execute: {
                                                                        self.imageView.image = userImage!
                                                                        //set title too
                                                                        if self.currentPhotoObj["title"] != nil {
                                                                            self.imageTitle.text = "Uploaded\n\(self.currentPhotoObj["title"] as! String)"
                                                                            self.removeIndicator(currentView: self.view)
                                                                        }
                                                                    })
                                                                }
                                                            }
                                                        }
                                                    })
                                                }
                                            }
                                        }
                                        
                                    }else{
                                        
                                        let alertController = UIAlertController(title: "Error", message: error.debugDescription, preferredStyle: .alert)
                                        let cancelAction = UIAlertAction(title: "OK", style: .default, handler: {
                                            (action : UIAlertAction!) -> Void in
                                        })
                                        alertController.addAction(cancelAction)
                                        DispatchQueue.main.async(execute: {
                                            self.present(alertController, animated: true, completion: nil)
                                            self.removeIndicator(currentView: self.view)
                                        })
                                        DispatchQueue.main.async(execute: {
                                            self.present(alertController, animated: true, completion: nil)
                                            self.removeIndicator(currentView: self.view)
                                        })
                                    }
                                }
                            }
                        })
                    }
                })
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
                    (action : UIAlertAction!) -> Void in
                    
                })
                alertController.addAction(saveAction)
                alertController.addAction(cancelAction)
                DispatchQueue.main.async(execute: {
                    self.present(alertController, animated: true, completion: nil)
                })
            })
        }
        
        self.dismiss(animated: true, completion:nil)
    }
    
    //MARK: CANCELLED PICKER
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
        let alertController = UIAlertController(title: "Closed", message: "Select an image to upload.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
        })
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
        self.removeIndicator(currentView: self.view)
    }
    
}

