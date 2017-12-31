//
//  AppDelegate.swift
//  JapList
//
//  Created by Dane Miller on 12/14/17.
//  Copyright © 2017 Dane Miller. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let stack = CoreDataStack(modelName: "Model")!



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()

        stack.autoSave(15)
        print(5)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        
        stack.save()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
        stack.save()
    }

    

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

