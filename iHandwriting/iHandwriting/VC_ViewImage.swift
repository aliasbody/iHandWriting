//
//  VC_ViewImage.swift
//  iHandwriting
//
//  Created by Luis Da Costa on 15/06/16.
//  Copyright © 2016 Luis Da Costa. All rights reserved.
//


import UIKit

class VC_ViewImage: UIViewController {
    
    // ScrollView Outlet used to zoom on the returned Image
    @IBOutlet weak var scrollView: UIScrollView!
    
    // ImageView Outlet used to display the returned Image
    @IBOutlet weak var imageView: UIImageView!
    
    // Internal variable used to store the returned Image (before segue)
    internal var resultImage = UIImage()
    
    /*
     Called when the view is loaded
     
     Defines the imageView (inside the scrollView) as the returned Image from the resultImage variable
     Defines the actual zoomScale  at 1
     Defines the maximum zoomScale at 5
     Defines the minimum zoomScale at 1
     **/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageView.image = resultImage
        
        self.scrollView.zoomScale          = 1
        self.scrollView.maximumZoomScale   = 5.0
        self.scrollView.minimumZoomScale   = 1
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     IBAction called when tapped on the TopBar Send action button
     
     Calls the UIActivitiViewController with the FinalImage as the only activityItems in order to display the Share
     View from iOS which allows the user to share the image with native and third-party apps on his device

     - Parameters:
        - sender: Receives the <AnyObject> tapped
     */
    @IBAction func btnBarSaveOrEmail_Action(sender: AnyObject) {
        let vc = UIActivityViewController(activityItems: [resultImage], applicationActivities: [])
        presentViewController(vc, animated: true, completion: nil)
    }
}

/**
 Extends UIScrollViewDelegate to the VC_ViewImage Class
*/
extension VC_ViewImage : UIScrollViewDelegate {
    /**
     Delegate function from UIScrollViewDelegate called when the Zoom is being done
     
     Simply defines that if the width of height is inferior than the allowed value, then when the zoom is stopped
     simply return the center of the image to the center of scrollview (in order to always provide a centered view).
     
     - Parameters:
        - scrollView: Receives the ScrollView used then zooming
     */
    func scrollViewDidZoom(scrollView: UIScrollView) {
        if self.imageView.frame.height <= scrollView.frame.height {
            let shiftHeight = scrollView.frame.height/2.0 - scrollView.contentSize.height/2.0
            scrollView.contentInset.top = shiftHeight
        }
        if self.imageView.frame.width <= scrollView.frame.width {
            let shiftWidth = scrollView.frame.width/2.0 - scrollView.contentSize.width/2.0
            scrollView.contentInset.left = shiftWidth
        }
    }
    
    /**
     Delegate function from UIScrollViewDelegate triggered when the UIScrollView needs to know what view to scroll
     
     - Parameters:
        - scrollView: Receives the ScrollView used to zoom
     
     - Returns:
        - UIView containing the final Image (which is used to do the scroll)
     */
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}