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
    
    @IBOutlet weak var signInBackgroundImage: UIImageView!
    @IBOutlet weak var backgroundBlur: UIVisualEffectView!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var logoutBtn: UIBarButtonItem!
    
    
    private let refreshControl = UIRefreshControl()

    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var user : User?
    var decks : [DocumentSnapshot]! = []
    var defStore : Firestore? = nil
    var defAuth : FUIAuth? = nil
    var selDeck : DocumentSnapshot? = nil
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    let ActInd = MyActInd()
    var listenersActive : Bool? = false

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRefreshLayout()
        setupFlowLayout()
        firestoreSetup()
        configureAuth()
        
    }
    
    
    
    
    @IBAction func logout(_ sender: Any) {
        let okAction : UIAlertAction  = UIAlertAction(title: "Yes, I'm Sure", style: .destructive, handler: { (action) in
            print("Logged out")
            try! Auth.auth().signOut()
            
        })
        let cancelAction : UIAlertAction  = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alert(title: "Are you sure?", message: "This will log you out and you will not be able to access any public decks.", controller: self, actions: [okAction, cancelAction])
    }
    
    
    @IBAction func signIn(_ sender: Any) {
        self.loginSession()
    }
    
    
    func firestoreSetup(){
        
        defStore = Firestore.firestore()
        
    }
    
    func populateDeck(_ reloading : Bool = false){
        if !ReachabilityTest.isConnectedToNetwork() && reloading{
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                performUIUpdatesOnMain {
                    
                
                    if self.onlineDecks.refreshControl != nil{
                        self.onlineDecks.refreshControl!.endRefreshing()
                        
                    } else {
                        self.refreshControl.endRefreshing()

                    }

                }

            })
            alert(title: "Error reloading data", message: "Please check network connection.", controller: self,
                  actions: [okAction])
            return
        }
        
        
        ActInd.show(onlineDecks!)
        monitorNetworkViaUI(true)
        defStore?.collection("public_decks").getDocuments() { (querySnapshot, err) in
            performUIUpdatesOnMain {
                monitorNetworkViaUI(false)
                if reloading{
                   
                        if self.onlineDecks.refreshControl != nil{
                            self.onlineDecks.refreshControl!.endRefreshing()
                            
                        } else {
                            self.refreshControl.endRefreshing()
                            
                        }

                }
                self.ActInd.hide()
                if !self.listenersActive!{
                    self.addListeners()
                    self.listenersActive = true
                }
                
                
                if let err = err {
                    print("Error getting documents: \(err)")
                    alert(title: "Error", message: "Could not retrieve decks.", controller: self)

                } else {
                    
                    self.decks = querySnapshot!.documents
                    
                    self.onlineDecks.reloadData()

                }
                if !ReachabilityTest.isConnectedToNetwork(){
                    alert(title: "Notice", message: "Data shown is the last cached copy. Could not establish connection.", controller: self)
                }
            }
        }
    }
    
    
    // These monitor for changes thus cannot alert in here.
    func addListeners(){
        let options = QueryListenOptions()
        options.includeQueryMetadataChanges(true)

        defStore?.collection("public_decks").addSnapshotListener(options: options){ (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                print("Error fetching updates")
                return
            }
            snapshot.documentChanges.forEach({ (diff) in
                if(diff.type == .added){
                    print("added")
                    if !self.decks.contains(diff.document){
                        performUIUpdatesOnMain {
                            self.decks.append(diff.document)
                            self.onlineDecks.insertItems(at: [IndexPath(row: self.decks.count - 1, section : 0 )])
                        }
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
        }
        
    }
    
    func findDocument(doc : DocumentSnapshot)->Int{
        var ind : Int = 0
        for deck in decks {
            if deck.documentID == doc.documentID{
                return ind
            }
            ind += 1
            
        }
        return -1
        
    }
    
    @objc private func refreshDeckData(_ sender: Any) {
        populateDeck(true)
    }
    

    func signedInStatus(isSignedIn: Bool) {
        navbar.titleView?.isHidden = !isSignedIn
        onlineDecks.isHidden = !isSignedIn
        backgroundBlur.isHidden = isSignedIn
        signInBackgroundImage.isHidden = isSignedIn
        signInButton.isHidden = isSignedIn
        logoutBtn.isEnabled = isSignedIn
        if isSignedIn {
            logoutBtn.tintColor = .red
        } else {
            logoutBtn.tintColor = .clear

        }
    }
    
    func loginSession() {
        let authViewController = FUIAuth.defaultAuthUI()!.authViewController()
        present(authViewController, animated: true, completion: nil)
    }
    
    func configureAuth() {
        let provider: [FUIAuthProvider] = [FUIGoogleAuth()]
        FUIAuth.defaultAuthUI()?.providers = provider
        
        _authHandle = Auth.auth().addStateDidChangeListener { (auth: Auth, user: User?) in
            
            if let activeUser = user {

                if self.user != activeUser {
                    self.user = activeUser
                    self.signedInStatus(isSignedIn: true)
                    self.populateDeck()
                }
            } else {
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
    func setupFlowLayout(){
        let space:CGFloat = 8.0
        let dimension = (onlineDecks.frame.size.width - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: 200.0)
        flowLayout.scrollDirection = .vertical
    }
    
    func setupRefreshLayout(){
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            onlineDecks.refreshControl = refreshControl
        } else {
            onlineDecks.addSubview(refreshControl)
        }
        
        // Configure Refresh Control
        refreshControl.addTarget(self, action: #selector(refreshDeckData(_:)), for: .valueChanged)
    }
    
    
    
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
            setImage(imageView: cell.coverImage, delegate: self.delegate, lnk: cover_url as? String, snap: true)
          
        } else {
            cell.coverImage.image = UIImage(named: "Placeholder")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        selDeck = decks[indexPath.row]
        performSegue(withIdentifier: Constants.SegueIdentifiers.deckDetails, sender: self)
    }
    
    
}


