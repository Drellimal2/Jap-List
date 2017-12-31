//
//  DiscoverViewController.swift
//  JapList
//
//  Created by Dane Miller on 12/18/17.
//  Copyright © 2017 Dane Miller. All rights reserved.
//

import UIKit
import Firebase

class DiscoverViewController: UIViewController {

    @IBOutlet weak var onlineDecks: UICollectionView!
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var decks : [DocumentSnapshot]! = []
    var defaultStore : Firestore? = nil
    let imageCache = NSCache<NSString, UIImage>()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFlowLayout()
        defaultStore = Firestore.firestore()
        populateDeck()
        addListeners()
    }
    
    func populateDeck(){
        defaultStore?.collection("public_decks").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                alert(title: "Error", message: "Could not retrieve decks.", controller: self)
            } else {
                performUIUpdatesOnMain {
                print(querySnapshot!.documents.count)
                var count = 0
                for document in querySnapshot!.documents {
                    self.decks.append(document)
                    self.onlineDecks.insertItems(at: [IndexPath(row: (self.decks.count)-1, section: 0)])
                    
                    count += 1
                }
                
                    self.onlineDecks.reloadData()

                }
            }
        }

    }
    
    func addListeners(){
        defaultStore?.collection("public_decks").addSnapshotListener({ (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                print("Error fetching updates")
                return
            }
            snapshot.documentChanges.forEach({ (diff) in
                if(diff.type == .added){
                    performUIUpdatesOnMain {
                        self.decks.append(diff.document)
                        self.onlineDecks.insertItems(at: [IndexPath(row: self.decks.count - 1, section : 0 )])
                    }
                }
                if(diff.type == .modified){
                    let ind = self.findDocument(doc: diff.document)
                    performUIUpdatesOnMain {
                        self.decks[ind] = diff.document
                        self.onlineDecks.reloadItems(at: [IndexPath(row: ind, section : 0 )])
                    }
                    
                }
                
                if(diff.type == .removed){
                    let ind = self.findDocument(doc: diff.document)
                    performUIUpdatesOnMain {
                        self.decks.remove(at: ind)

                        self.onlineDecks.deleteItems(at: [IndexPath(row: ind, section : 0 )])

                    }
                    
                }
            })
        })
        
    }
    
    func findDocument(doc : DocumentSnapshot)->Int{
        var ind : Int = 0
        for deck in decks {
            if deck.documentID == doc.documentID{
                print(ind)
                return ind
            }
            ind += 1
            
        }
        return -1
        
        
    }
    
    func setupFlowLayout(){
        let space:CGFloat = 8.0
        let dimension = (onlineDecks.frame.size.width - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        flowLayout.scrollDirection = .vertical
    }

    

}


extension DiscoverViewController : UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (decks?.count)!
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "onlineDeckCell", for: indexPath) as! DeckCollectionViewCell
        let deckSnapshot : DocumentSnapshot! = decks[indexPath.row]
        
        let deck = deckSnapshot.data() as! [String: String]
        let title = deck[Constants.SnapshotFields.title]
        let desc = deck[Constants.SnapshotFields.desc] ?? ""
        print(title)
        print(desc)
        cell.title.text = title
        if let cover_url = deckSnapshot[Constants.SnapshotFields.cover] {
            Storage.storage().reference(forURL :  cover_url as! String).getData(maxSize: INT64_MAX, completion: { (data, error) in
                guard error == nil else{
                    performUIUpdatesOnMain {
                        alert(title: "Error Loading Image", message: "Could not load cover image",controller: self )
                        
                    }
                    return
                }
                performUIUpdatesOnMain {
                    let coverImage = UIImage.init(data: data!, scale : 50)
                    cell.coverImage.image = coverImage
                    
                }
                
                
            })
            
        
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("heyo")
    }
    
    
}

