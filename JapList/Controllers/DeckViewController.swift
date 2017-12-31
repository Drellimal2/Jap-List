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

class DeckViewController: UIViewController {
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var stack : CoreDataStack? = nil
    var deck : Deck? = nil
    var cards : [Card]? = nil
    var deckDocument : DocumentSnapshot? = nil
    var cardSnapshots : [DocumentSnapshot]? = nil
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var descTextView: UITextView!
    var defaultStore : Firestore? = nil
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var wordTable: UITableView!
    @IBOutlet weak var newWordBtn: UIButton!
    @IBOutlet weak var reviewBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var otherBtn: UIButton!
    
    var isSnap :Bool? = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stack = delegate.stack
        setup()
        subscribeToNotification(.NSManagedObjectContextObjectsDidChange, selector: #selector(managedObjectContextObjectsDidChange), object: stack?.context, controller: self)        // Do any
    }

    func setupSnapshot(){
        let deckdoc = deckDocument?.data() as! [String : String]
        titleLabel.text = deckdoc[Constants.SnapshotFields.title]
        //coverImage.image = UIImage(data: (deck?.cover)! as Data)
        descTextView.text = deckdoc[Constants.SnapshotFields.desc] ?? "No description"
        cards = []
        cardSnapshots = []
        defaultStore = delegate.defaultStore
        reviewBtn.isHidden = true
        deleteBtn.isHidden = true
        otherBtn.isHidden = false
        otherBtn.titleLabel?.text = "Save"
        populateCardSnaps()
    }
    
    func populateCardSnaps(){
        defaultStore?.collection("public_decks").document((deckDocument?.documentID)!).collection("cards").getDocuments(completion: {  (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    alert(title: "Error", message: "Could not retrieve decks.", controller: self)
                } else {
                    performUIUpdatesOnMain {
                        print(querySnapshot!.documents.count)
                        var count = 0
                        for document in querySnapshot!.documents {
                            self.cardSnapshots?.append(document)
                            self.wordTable.insertRows(at: [IndexPath(row: (self.cardSnapshots?.count)!-1, section: 0)], with: .automatic)
                            count += 1
                        }
                        
                        
                    }
                }
            
            
        })
    }
    
    func setupCoreData(){
        titleLabel.text = deck?.name
        coverImage.image = UIImage(data: (deck?.cover)! as Data)
        descTextView.text = deck?.description
        cards = Array((deck?.cards)!) as? [Card]
        
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
        alert(title: "Error", message: "Deck Could not be loaded", controller: self)
        self.navigationController?.popViewController(animated: true)

    }
    
    @IBAction func addWord(_ sender: Any) {
        performSegue(withIdentifier: Constants.SegueIdentifiers.newCard, sender: self)
    }
    
}

extension DeckViewController{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.SegueIdentifiers.newCard {
            let dest = segue.destination as! NewCardViewController
            dest.deck = deck
        }
        print(segue.destination)
    }
    
}

extension DeckViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        print(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSnap!{
            return (cardSnapshots?.count)!
        } else {
            return (cards?.count)!
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: CardTableViewCell! = tableView.dequeueReusableCell(withIdentifier: "cardTableCell", for: indexPath) as! CardTableViewCell
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
        
        
        return cell!
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
            
            print("Inserted Card \(inserts.count)")
            
        }
        
        if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>, updates.count > 0 {
            print("Updated \(updates.count)")
        }
        
        if let deletes = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>, deletes.count > 0 {
            print("Deleted \(deletes.count)")
        }
    }
    
}
