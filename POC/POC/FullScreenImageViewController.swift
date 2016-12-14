//
//  FullScreenImageViewController.swift
//  POC
//
//  Created by Umar Farooque on 08/12/16.
//  Copyright © 2016 temp. All rights reserved.
//

import UIKit

class FullScreenImageViewController: UIViewController {
    

    //VARIABLES & OUTLETS
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    var imageToDisplay : UIImage?
    
    
    //MARK: VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.delegate = self
        self.scrollView.contentSize = (self.imageView.image?.size)!
        self.imageView.frame = CGRect(x: 0, y: 0, width: (self.imageView.image?.size.width)!, height: (self.imageView.image?.size.height)!)
        if imageToDisplay != nil {
            self.imageView.image = imageToDisplay!
        }
    }
    

    //MARK: BUTTON ACTION
    
    @IBAction func closeButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

    //MARK: SCROLLVIEW DELEGATE
extension FullScreenImageViewController :UIScrollViewDelegate{
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView        
    }
}
