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
            print(error!)
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

func startUpload(defaultStore : Firestore, deck : Deck, completionHandler : @escaping (_ error:String?)->Void){
    let user = getCurrentUser()?.uid
    let docref = defaultStore.collection("public_decks").document()
    saveImageToFirebase(photoData: deck.cover! as Data, refId: docref, defaultStore: defaultStore, completionHandler: completionHandler)
    defaultStore.collection("public_decks").document(docref.documentID).setData([
        Constants.SnapshotFields.title : deck.name!,
        Constants.SnapshotFields.desc : deck.desc!,
        Constants.SnapshotFields.coredataref : user! + deck.objectID.description
        
        
    ]){
        (error) in
        if error != nil{
            print("Can't save")
            
        }
        defaultStore.collection("user_decks").document(user!).collection("decks").addDocument(data: [
            Constants.SnapshotFields.ref: docref])
        for crd in deck.cards! {
            let card = crd as! Card
            docref.collection("cards").document(card.objectID.description).setData([
                Constants.SnapshotFields.kanji : card.kanji!,
                Constants.SnapshotFields.kana : card.kana!,
                Constants.SnapshotFields.trans : card.translation!
                ])
        }
    }
    
    
}

func startUpdateUpload(defaultStore : Firestore, deck : Deck , completionHandler : @escaping (_ error:String?)->Void){
    let user = getCurrentUser()?.uid
    defaultStore.collection("public_decks").whereField(Constants.SnapshotFields.coredataref, isEqualTo: user! + getObjectIdUniqueString(obj: deck)).getDocuments { (querySnapshot, error) in
        if error != nil {
            print("Error")
            completionHandler("Error trying to find deck.")
            return
        }
        querySnapshot?.documents.forEach({ (doc) in
            doc.reference.setData([
                Constants.SnapshotFields.title : deck.name!,
                Constants.SnapshotFields.desc : deck.desc!,
                ], options: SetOptions.merge())
            
            saveImageToFirebase(photoData: deck.cover! as Data, refId: doc.reference, defaultStore: defaultStore, completionHandler : completionHandler)
            for crd in deck.cards! {
                let card = crd as! Card
                doc.reference.collection("cards").document(card.objectID.uriRepresentation().pathComponents[card.objectID.uriRepresentation().pathComponents.count - 1]).setData([
                    Constants.SnapshotFields.kanji : card.kanji!,
                    Constants.SnapshotFields.kana : card.kana!,
                    Constants.SnapshotFields.trans : card.translation!
                    ])
            }
        })
        if querySnapshot?.documents.count == 0 {
            let docref = defaultStore.collection("public_decks").document()
            let newref = defaultStore.collection("user_decks").document(user!).collection("decks").addDocument(data: [
                Constants.SnapshotFields.ref: docref,
                "temp" : "t"])
            saveImageToFirebase(photoData: deck.cover! as Data, refId: docref, defaultStore: defaultStore, userref : newref, completionHandler : completionHandler)
            defaultStore.collection("public_decks").document(docref.documentID).setData([
                Constants.SnapshotFields.title : deck.name!,
                Constants.SnapshotFields.desc : deck.desc!,
                Constants.SnapshotFields.coredataref : user! + getObjectIdUniqueString(obj: deck)
             
                ])
            
            for crd in deck.cards! {
                let card = crd as! Card
                docref.collection("cards").document(card.objectID.uriRepresentation().pathComponents[card.objectID.uriRepresentation().pathComponents.count - 1]).setData([
                    Constants.SnapshotFields.kanji : card.kanji!,
                    Constants.SnapshotFields.kana : card.kana!,
                    Constants.SnapshotFields.trans : card.translation!
                    ])
            }
        }
    }
}


func saveImageToFirebase(photoData : Data, refId : DocumentReference, defaultStore : Firestore, userref : DocumentReference? = nil, completionHandler : @escaping (_ error:String?)->Void){
    let storageRef = Storage.storage().reference()
    // build a path using the user’s ID and a timestamp
    let imagePath = "deck_covers/" + refId.documentID + "_cover.jpg"
    // set content type to “image/jpeg” in firebase storage metadata
    let metadata = StorageMetadata()
    metadata.contentType = "image/jpeg"
    // create a child node at imagePath with imageData and metadata
    storageRef.child(imagePath).putData(photoData, metadata: metadata) { (metadata, error) in
        if let error = error {
            completionHandler("Error uploading image.")

            print("Error uploading: \(error)")
            return
        }
        // use sendMessage to add imageURL to database
        completeUpload(data: [Constants.SnapshotFields.cover
            : storageRef.child((metadata?.path)!).description], refId: refId, defaultStore: defaultStore, userref: userref, completionHandler : completionHandler)
    }
}
func completeUpload(data:[String:String], refId:DocumentReference, defaultStore : Firestore, userref : DocumentReference? = nil, completionHandler : @escaping (_ error:String?)->Void){
    let user = getCurrentUser()?.uid

        refId.setData(data, options: SetOptions.merge())
    if let userRef = userref{
        print("Here boo")
        userRef.updateData(["temp" : FieldValue.delete(),
                             ]) { err in
                                if let err = err {
                                    completionHandler("Error updating user document")
                                } else {
                                    print("Document successfully updated")
                                    completionHandler(nil)
                                }
        }
    } else {
        defaultStore.collection("user_decks").document(user!).collection("decks").whereField(Constants.SnapshotFields.ref, isEqualTo: refId).getDocuments { (querySnapshot, error) in
            if error != nil {
                print("Error")
                completionHandler("Error updating user document")
                return
            }
            querySnapshot?.documents.forEach({ (doc) in
                doc.reference.setData([
                    "temp" : "t"
                    ], options: SetOptions.merge())
                doc.reference.updateData(["temp" : FieldValue.delete(),
                                          ]) { err in
                                            if let err = err {
                                                print("Error updating document: \(err)")
                                                completionHandler("Error updating user document")
                                            } else {
                                                print("Document successfully updated")
                                                completionHandler(nil)
                                            }
                
                    
                }
            })
        }
    }
}




