//
//  GlobalExtensions.swift
//  iHandwriting
//
//  Created by Luis Da Costa on 15/06/16.
//  Copyright © 2016 Luis Da Costa. All rights reserved.
//

import UIKit

extension UIAlertController {
    /**
     Creates an alert with a rotating loading (UIActivityIndicatorView) and a message (Loading...)

     - Returns: A UIAlertViewController to show/dismiss when needed
     */
    class func loadingAlert() -> UIAlertController {
        let alert = UIAlertController(title: nil, message: "Loading...", preferredStyle: .Alert)
        
        alert.view.tintColor = UIColor.blackColor()
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(10, 5, 50, 50)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        
        return alert
    }
}

extension UIColor {
    /**
     From a UIColor value, returns a String with the HEX value based on Red, Green, Blue, Alpha
     Ex: UIColor.blackColor() = #000000
     
     - Returns: A String starting with '#' followed by the 6 digits of the Color HEX Value
     */
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return NSString(format:"#%06x", rgb) as String
    }
}

extension NSArray {
    /**
     Orders (ASC or DESC) the NSArray of Strings, based on the privided Key, used to call this function
     
     - Parameters:
        - key      : The String of the key used to order the NSArray.
        - ascending: Bool used to define the final ordering (true = ASC, false = DESC)

     - Returns: Returns the used NSArray ordered by the Key
     */
    func orderByAlpha(key: String, ascending: Bool) -> NSArray {
        return sortedArrayUsingDescriptors([NSSortDescriptor(key: key, ascending: ascending)])
    }
}

extension UIViewController {
    /**
     Simple function to display a classic 'OK' Alert. This is used to have a clearer code on the main files.
     
     - Parameters:
        - title    : String containting the title to be displayed on the Alert.
        - message  : String containting the message to be displayed on the Alert.
     */
    func displaySimpleOKAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil ))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}