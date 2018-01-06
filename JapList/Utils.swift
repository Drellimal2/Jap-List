//
//  Utils.swift
//  JapList
//
//  Created by Dane Miller on 12/21/17.
//  Copyright © 2017 Dane Miller. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import SystemConfiguration

func isFirstTime()->Bool{
    if UserDefaults.standard.object(forKey: Constants.UserDefaultKeys.firstTime) == nil{
        UserDefaults.standard.set(false, forKey: Constants.UserDefaultKeys.firstTime)
        UserDefaults.standard.set(true, forKey: Constants.UserDefaultKeys.firstCard)
        UserDefaults.standard.set(true, forKey: Constants.UserDefaultKeys.firstDeck)
        UserDefaults.standard.set(true, forKey: Constants.UserDefaultKeys.firstReview)
        UserDefaults.standard.set(true, forKey: Constants.UserDefaultKeys.firstDeckDetails)
        
        return true
    }
    return false
    
}

func isFirstDeck()->Bool{
    if UserDefaults.standard.bool(forKey: Constants.UserDefaultKeys.firstDeck){
        UserDefaults.standard.set(false, forKey: Constants.UserDefaultKeys.firstDeck)
        return true
    } else {
        return false
    }
}



func monitorNetworkViaUI(_ show : Bool){
    performUIUpdatesOnMain {
        UIApplication.shared.isNetworkActivityIndicatorVisible = show
    }
}











func subscribeToNotification(_ name: NSNotification.Name, selector: Selector, object : Any? = nil, controller : UIViewController ) {
    NotificationCenter.default.addObserver(controller, selector: selector, name: name, object: object)
}

func unsubscribeFromAllNotifications(controller : UIViewController ) {
    NotificationCenter.default.removeObserver(controller)
}

func alert(title : String, message : String, controller : UIViewController, actions : [UIAlertAction] = []){
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    if actions.count == 0{
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    } else {
        for action in actions{
            alert.addAction(action)
        }
    }
    controller.present(alert, animated: true, completion: nil)
}

func setImage(imageView : UIImageView, delegate : AppDelegate, lnk : String?, snap : Bool){
    if lnk == nil{
        imageView.image = UIImage(named : "Placeholder")
        return
    }
    let link = lnk!
    if let cachedImage = delegate.imageCache.object(forKey: link as NSString) {
        imageView.image = cachedImage
    } else {
        if snap {
            Storage.storage().reference(forURL: link).getData(maxSize: INT64_MAX, completion: { (data, error) in
                guard error == nil else {
                    print("Error downloading: \(error!)")
                    return
                }
                let messageImage = UIImage.init(data: data!, scale: 50)
                delegate.imageCache.setObject(messageImage!, forKey: link as NSString)
                performUIUpdatesOnMain {
                    
                
                    imageView.image = messageImage
                }
                
            })
        } else {
            URLSession.shared.dataTask(with: NSURL(string: link)! as URL, completionHandler: { (data, response, error) -> Void in
                
                if error != nil {
                    print(error!)
                    return
                }
                let image = UIImage(data: data!)
                performUIUpdatesOnMain {
                    imageView.image = image
                }
                
            }).resume()
        }
    }
}


public class ReachabilityTest {
    
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
        
    }
    
}
