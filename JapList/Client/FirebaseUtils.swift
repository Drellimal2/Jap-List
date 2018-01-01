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

func getUserListSnapshot(defaultStore : Firestore) -> CollectionReference?{
    if let currentUser = getCurrentUser()?.uid {
        return defaultStore.collection("user_decks").document(currentUser).collection("decks")
    } else {
        return nil
    }
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

func checkIsinUserDeck(defaultStore : Firestore, doc : DocumentSnapshot, controller : UIViewController,
                       completionHandler : @escaping (_ res :Bool?, _ error : Error?)->Void){
    let collSnap = getUserListSnapshot(defaultStore: defaultStore)
    collSnap?.whereField(Constants.SnapshotFields.ref, isEqualTo: doc.reference).getDocuments(completion: { (querySnapshot, error) in
        if error != nil {
            completionHandler(false, error)
            return
        }
        if (querySnapshot?.documents.count)! > 0{
            completionHandler(true, nil)
        } else {
            completionHandler(false, nil)
        }
        return
        
    })
    
}

func deleteDeckFromUserLists(defaultStore : Firestore, doc : DocumentSnapshot){
    
    let collSnap = getUserListSnapshot(defaultStore: defaultStore)
    collSnap?.whereField(Constants.SnapshotFields.ref, isEqualTo: doc.reference).getDocuments(completion: { (querySnapshot, error) in
        if error != nil {
            print(error)
        } else {
            querySnapshot?.documents.forEach({ (doc) in
                doc.reference.delete(){ err in
                    if let err = err {
                        print("Error removing document: \(err)")
                    } else {
                        print("Document successfully removed!")
                    }
                }
            })
        }
    })
}



