//
//  DiscoverViewController.swift
//  JapList
//
//  Created by Dane Miller on 12/18/17.
//  Copyright © 2017 Dane Miller. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI
import FirebaseGoogleAuthUI


class DiscoverViewController: UIViewController {

    @IBOutlet weak var onlineDecks: UICollectionView!
    
    @IBOutlet weak var navbar: UINavigationItem!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    var user : User?
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var decks : [DocumentSnapshot]! = []
    var defaultStore : Firestore? = nil
    let imageCache = NSCache<NSString, UIImage>()
    var selDeck :DocumentSnapshot? = nil
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!

    @IBOutlet weak var signInBackgroundImage: UIImageView!
    
    @IBOutlet weak var backgroundBlur: UIVisualEffectView!
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFlowLayout()
        firestoreSetup()
        populateDeck()
        addListeners()
        configureAuth()
    }
    
    @IBAction func signIn(_ sender: Any) {
        self.loginSession()
    }
    func firestoreSetup(){
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true

        defaultStore = Firestore.firestore()
        defaultStore?.settings = settings

        
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
        flowLayout.itemSize = CGSize(width: dimension, height: 200.0)
        flowLayout.scrollDirection = .vertical
    }

    func signedInStatus(isSignedIn: Bool) {
        navbar.titleView?.isHidden = !isSignedIn
        onlineDecks.isHidden = !isSignedIn
        backgroundBlur.isHidden = isSignedIn
        signInBackgroundImage.isHidden = isSignedIn
        signInButton.isHidden = isSignedIn
        
        if isSignedIn {
//            populateDeck()
            print("hey")
        }
    }
    
    func loginSession() {
        let authViewController = FUIAuth.defaultAuthUI()!.authViewController()
        present(authViewController, animated: true, completion: nil)
    }
    
    func configureAuth() {
        let provider: [FUIAuthProvider] = [FUIGoogleAuth()]
        FUIAuth.defaultAuthUI()?.providers = provider
        
        // listen for changes in the authorization state
        _authHandle = Auth.auth().addStateDidChangeListener { (auth: Auth, user: User?) in
            // refresh table data
//            self.decks.removeAll(keepingCapacity: false)
//            self.onlineDecks.reloadData()
            
            // check if there is a current user
            if let activeUser = user {
                // check if the current app user is the current FIRUser
                if self.user != activeUser {
                    self.user = activeUser
                    self.signedInStatus(isSignedIn: true)
                }
            } else {
                // user must sign in
                self.signedInStatus(isSignedIn: false)
            }
        }
    }

}

extension DiscoverViewController{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.SegueIdentifiers.deckDetails {
            let dest = segue.destination as! DeckViewController
            dest.deckDocument = selDeck
            selDeck = nil
        }
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
        let _ = deck[Constants.SnapshotFields.desc] ?? ""
        cell.title.text = title
        if let cover_url = deckSnapshot[Constants.SnapshotFields.cover] {
            setImage(imageView: cell.coverImage, delegate: self.delegate, link: cover_url as! String, snap: true)
          
        
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        selDeck = decks[indexPath.row]
        performSegue(withIdentifier: Constants.SegueIdentifiers.deckDetails, sender: self)
    }
    
    
}


