//
//  DeckViewController.swift
//  JapList
//
//  Created by Dane Miller on 12/18/17.
//  Copyright © 2017 Dane Miller. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import XCGLogger

class DeckViewController: UIViewController {
    
    
    // UI Elements
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var wordTable: UITableView!
    @IBOutlet weak var newWordBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var reviewBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var otherBtn: UIButton!
    
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var log : XCGLogger?
    var defaultStore : Firestore? = nil
    var saveSnap :Bool? = true
    var isSnap :Bool? = false
    var stack : CoreDataStack? = nil
    var deck : Deck? = nil
    var cards : [Card]? = nil
    var deckDocument : DocumentSnapshot? = nil
    var cardSnapshots : [DocumentSnapshot]? = nil
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        stack = delegate.stack
        log = delegate.log
        setup()
        subscribeToNotification(.NSManagedObjectContextObjectsDidChange, selector: #selector(managedObjectContextObjectsDidChange), object: stack?.context, controller: self)
    }

    func setupSnapshot(){
        let deckdoc = deckDocument?.data() as! [String : String]
        titleLabel.text = deckdoc[Constants.SnapshotFields.title]
        descLabel.text = deckdoc[Constants.SnapshotFields.desc] ?? "No description"
        
        let coverlink = deckdoc[Constants.SnapshotFields.cover]
        setImage(imageView: self.coverImage, delegate: self.delegate, lnk: coverlink, snap: true)

        cards = []
        cardSnapshots = []
        defaultStore = delegate.defaultStore
        newWordBtn.isHidden = true
        reviewBtn.isHidden = false
        deleteBtn.isHidden = true
        otherBtn.isHidden = false
        editBtn.isHidden = true
        otherBtn.titleLabel?.text = "Save"
        populateCardSnaps()
        addSaveListener()
    }
    
    func populateCardSnaps(){
                monitorNetworkViaUI(true)
            defaultStore?.collection("public_decks").document((deckDocument?.documentID)!).collection("cards").getDocuments(completion: {  (querySnapshot, err) in
                performUIUpdatesOnMain {
                    monitorNetworkViaUI(false)
                }
                self.addCardListeners()
                if let err = err {
                    self.log?.error("Error fetching cards \(err)")
                    performUIUpdatesOnMain {
                        
                        alert(title: "Error", message: "Could not retrieve decks.", controller: self)
                    }
                } else {
                    performUIUpdatesOnMain {
                        self.log?.info("Loaded \(querySnapshot!.documents.count) cards")
                        var count = 0
                        for document in querySnapshot!.documents {
                            self.cardSnapshots?.append(document)
                            self.wordTable.insertRows(at: [IndexPath(row: (self.cardSnapshots?.count)!-1, section: 0)], with: .automatic)
                            count += 1
                        }
                        performUIUpdatesOnMain {
                            if !ReachabilityTest.isConnectedToNetwork(){
                                if count == 0{
                                    alert(title: "Error loading cards.", message: "Cards could not be loaded due to connection issues. Please check your connection.", controller: self)
                                } else {
                                    alert(title: "Notice", message: "You are viewing cached cards. Cards could not be loaded due to connection issues. Please check your connection.", controller: self)
                                }
                            }
                        }
                    }
                }
        })
    }
    
    
    func setupCoreData(){
        titleLabel.text = deck?.name
        coverImage.image = UIImage(data: (deck?.cover)! as Data)
        descLabel.text = deck?.desc
        cards = Array((deck?.cards)!) as? [Card]
        reviewBtn.isHidden = false
        deleteBtn.isHidden = false
        otherBtn.isHidden = true
        wordTable.allowsMultipleSelectionDuringEditing = false
        
    }
    func setup(){
        if deck != nil{
            setupCoreData()
            return
        }
        if deckDocument != nil {
            setupSnapshot()
            isSnap = true
            return
        }
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
            self.navigationController?.popViewController(animated: true)

        }
        alert(title: "Error", message: "Deck Could not be loaded. You will be redirected back to previous screen.", controller: self, actions: [OKAction])

    }
    
    @IBAction func addWord(_ sender: Any) {
        performSegue(withIdentifier: Constants.SegueIdentifiers.newCard, sender: self)
    }
    
    @IBAction func saveUnsave(_ sender: Any) {
        if saveSnap!{
            FirebaseUtils.addDeckToUserLists(defaultStore: delegate.defaultStore!, doc: deckDocument!)
        } else {
            let okAction : UIAlertAction  = UIAlertAction(title: "Yes, I'm Sure", style: .destructive, handler: { (action) in
                FirebaseUtils.deleteDeckFromUserLists(defaultStore: self.delegate.defaultStore!, doc: self.deckDocument!)
            })
            let cancelAction : UIAlertAction  = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alert(title: "Are you sure?", message: "This will remove this deck from your Decks.", controller: self, actions: [okAction, cancelAction])
            
        }
    }
    
    @IBAction func deleteDeck(_ sender: Any) {
        let okAction : UIAlertAction  = UIAlertAction(title: "Yes, I'm Sure", style: .destructive, handler: { (action) in
            
            deleteLocalDeck(deck: self.deck!, stack: self.stack!)
            
        })
        let cancelAction : UIAlertAction  = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alert(title: "Are you sure?", message: "This will delete the deck permanently!", controller: self, actions: [okAction, cancelAction])
    }
    
}

extension DeckViewController{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.SegueIdentifiers.newCard {
            let dest = segue.destination as! NewCardViewController
            dest.deck = deck
        } else if segue.identifier == Constants.SegueIdentifiers.cardReview {
            let dest = segue.destination as! CardReviewViewController
            if isSnap! {
                dest.deckDocument = self.deckDocument
                dest.cardSnapshots = self.cardSnapshots
            } else {
                dest.cards = self.cards
                dest.deck = self.deck
            }
        } else if segue.identifier == Constants.SegueIdentifiers.editDeck {
            let dest = segue.destination as! NewDeckViewController
            dest.deck = self.deck
        }
    }
    
}

extension DeckViewController{
    
    func saveBtnSetup(_ isSave : Bool){
        saveSnap = !isSave
        if isSave{
            otherBtn.setTitle("Unsave", for: .normal)
        } else {
            otherBtn.setTitle("Save", for: .normal)

        }
    }
    
    func saveUnsavecheck(){
        FirebaseUtils.checkIsinUserDeck(defaultStore: self.defaultStore!, doc: self.deckDocument!, controller: self) { (isIn, error) in
            performUIUpdatesOnMain {
                
                
                if error == nil {
                    self.saveBtnSetup(isIn!)
                    self.saveSnap = !isIn!
                } else {
                    alert(title: "Error", message: "Could not check list", controller: self)
                }
            }
        }
    }
    
    func addSaveListener(){
        FirebaseUtils.getUserListSnapshot(defaultStore: defaultStore!)?.addSnapshotListener({ (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                self.log?.error("Error fetching save status.")
                return
            }
            snapshot.documentChanges.forEach({ (diff) in
                let a = diff.document.data()
                let docref = a[Constants.SnapshotFields.ref] as! DocumentReference
                if let mydocref = self.deckDocument?.reference{
                    if docref == mydocref{
                        if diff.type == .added {
                            self.saveBtnSetup(true)
                        }
                        
                        if diff.type == .removed {
                            self.saveBtnSetup(false)
                        }
                    }
                }
                
                
                
                
            })
        })
    
    }
    
    func addCardListeners(){
        defaultStore?.collection("public_decks").document((deckDocument?.documentID)!).collection("cards").addSnapshotListener({ (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                self.log?.error("Error fetching card updates")
                return
            }
            snapshot.documentChanges.forEach({ (diff) in
                
                if diff.type == .added {
                    let doc = diff.document
                    if !(self.cardSnapshots?.contains(doc))!{
                        self.cardSnapshots?.append(doc)
                        self.wordTable.insertRows(at: [IndexPath(row: (self.cardSnapshots!.count - 1), section : 0)], with: .automatic)
                        self.saveBtnSetup(true)
                    }
                }
                
                if diff.type == .removed {
                    self.saveBtnSetup(false)
                }
                
            })
        })
    }
    
}

extension DeckViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        self.log?.info("\(indexPath.row) clicked")

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSnap!{
            return (cardSnapshots?.count)!
        } else {
            return (cards?.count)!
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: CardTableViewCell! = tableView.dequeueReusableCell(withIdentifier: Constants.StoryboardIdentifiers.cardRow, for: indexPath) as! CardTableViewCell
        if isSnap! {
            let cardSnapshot = cardSnapshots![indexPath.row]
            let cardDoc = cardSnapshot.data() as! [String : String]
            cell.kanjiLabel.text = cardDoc[Constants.SnapshotFields.kanji] ?? ""
            cell.kanaLabel.text = cardDoc[Constants.SnapshotFields.kana] ?? ""
            cell.translationLabel.text = cardDoc[Constants.SnapshotFields.trans]
            
        } else {
            let card = cards![indexPath.row]
            cell.kanjiLabel.text = card.kanji
            cell.kanaLabel.text = card.kana
            cell.translationLabel.text = card.translation
        }
        cell.kanaLabel.isHidden = (cell.kanaLabel.text?.isEmpty)!
        cell.kanjiLabel.isHidden = (cell.kanjiLabel.text?.isEmpty)!

        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !isSnap!
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let card = cards![indexPath.row]
            let okAction : UIAlertAction  = UIAlertAction(title: "Yes, I'm Sure", style: .destructive, handler: { (action) in
                deleteLocalCard(deck: self.deck!, card: card, stack: self.stack!)
                self.log?.warning("Card delete initialized")
            })
            let cancelAction : UIAlertAction  = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alert(title: "Are you sure?", message: "This will delete the card permanently!", controller: self, actions: [okAction, cancelAction])
        }
    }
    
    
}


extension DeckViewController {
    
    @objc func managedObjectContextObjectsDidChange(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        if let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>, inserts.count > 0 {
            
            for insert in inserts{
                if insert is Card {
                    if (insert as! Card).deck == deck {
                        cards?.append(insert as! Card)
                        let last_ind_row = (cards?.count)! - 1
                        let last_ind = IndexPath.init(row: last_ind_row, section: 0)
                        wordTable.insertRows(at: [last_ind], with: .automatic)
                        wordTable.scrollToRow(at: last_ind, at: .bottom, animated: true)
                    }
                    
                }
                
            }
            self.log?.info("[++] Inserted \(inserts.count) cards")
            
        }
        
        if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>, updates.count > 0 {
            for update in updates{
                if update is Deck {
                    if deck?.objectID == (update as! Deck).objectID {
                        self.deck = update as? Deck
                        performUIUpdatesOnMain {
                            self.setupCoreData()
                        }
                    }
                }
                
            }
            self.log?.info("[!!] Updated \(updates.count) cards")

        }
        
        if let deletes = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>, deletes.count > 0 {
            for del in deletes {
                if del is Card {
                    if (cards?.contains(del as! Card))!{
                        
                        performUIUpdatesOnMain {
                            let ind = self.cards?.index(of: del as! Card)
                            self.cards?.remove(at: ind!)
                        
                            self.wordTable.deleteRows(at: [IndexPath(row: ind!, section : 0)], with: .fade)
                        }
                    }
                }
                if del is Deck{
                    if del.objectID == deck?.objectID{
                        performUIUpdatesOnMain {
                        
                        self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
            self.log?.info("[--] Deleted \(deletes.count) cards")
        }
    }
    
}
