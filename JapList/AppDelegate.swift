//
//  AppDelegate.swift
//  JapList
//
//  Created by Dane Miller on 12/14/17.
//  Copyright © 2017 Dane Miller. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let stack = CoreDataStack(modelName: "Model")!
    var defaultStore : Firestore? = nil
    let imageCache = NSCache<NSString, UIImage>()



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        firestoreSetup()
        
        stack.autoSave(60)
        return true
    }

    func firestoreSetup(){
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        
        defaultStore = Firestore.firestore()
        defaultStore?.settings = settings
        
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
        stack.save()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
        stack.save()
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication ?? "") ?? false
    }


}


