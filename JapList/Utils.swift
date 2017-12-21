//
//  Utils.swift
//  JapList
//
//  Created by Dane Miller on 12/21/17.
//  Copyright © 2017 Dane Miller. All rights reserved.
//

import Foundation
import UIKit


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
