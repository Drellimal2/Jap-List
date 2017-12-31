//
//  FirebaseUtils.swift
//  JapList
//
//  Created by Dane Miller on 12/31/17.
//  Copyright © 2017 Dane Miller. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuthUI
import UIKit




func getCurrentUser()->User?{
    return Auth.auth().currentUser
}

func getUserListSnapshot(defaultStore : Firestore) -> CollectionReference{
    let currentUser = getCurrentUser()?.uid

    return defaultStore.collection("user_decks").document(currentUser!).collection("decks")
}

func getUserPublicLists(defaultStore : Firestore, controller : UIViewController, completionHandler : @escaping (_ querySnapshot :QuerySnapshot?, _ error : Error?)->Void){
    
    let currentUser = getCurrentUser()?.uid
    
    defaultStore.collection("user_decks").document(currentUser!).collection("decks").getDocuments() { (querySnapshot, err) in
        
        
        
        completionHandler(querySnapshot, err)

    }
}

func addDeckToUserLists(defaultStore : Firestore, doc : DocumentSnapshot){
    let currentUser = getCurrentUser()?.uid
    
    defaultStore.collection("user_decks").document(currentUser!).collection("decks").addDocument(data: [
        Constants.SnapshotFields.ref : doc.reference
        
    ])
}



