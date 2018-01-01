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

func setImage(imageView : UIImageView, delegate : AppDelegate, link : String, snap : Bool){
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
