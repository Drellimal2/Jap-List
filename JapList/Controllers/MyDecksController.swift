//
//  MyDecksController.swift
//  JapList
//
//  Created by Dane Miller on 12/18/17.
//  Copyright © 2017 Dane Miller. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class MyDecksController: UIViewController {

    @IBOutlet weak var deckTableView: UITableView!
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var stack : CoreDataStack? = nil
    var defaultStore : Firestore? = nil
    var decks : [Deck] = []
    var deckSnapshots : [DocumentSnapshot] = []
    var selDeck : Deck? = nil
    var selSnap : DocumentSnapshot? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stack = delegate.stack
        defaultStore = delegate.defaultStore
        decks = getAllDecks(moc: (stack?.context)!)
        subscribeToNotification(.NSManagedObjectContextObjectsDidChange, selector: #selector(managedObjectContextObjectsDidChange), object: stack?.context)
//        populateDeck()
        addListeners()
    }

    @IBAction func addDeck(_ sender: Any) {
        performSegue(withIdentifier: Constants.SegueIdentifiers.newDeck, sender: self)
    }
    
    
    func populateDeck(){
        
        getUserPublicLists(defaultStore: defaultStore!, controller: self) { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                alert(title: "Error", message: "Could not retrieve decks.", controller: self)
            } else {
                performUIUpdatesOnMain {
                    print(querySnapshot!.documents.count)
                    var count = 0
                    for document in querySnapshot!.documents {
                        let a = document.data()
                        let docref = a[Constants.SnapshotFields.ref] as! DocumentReference
                        docref.getDocument(completion: { (doc, err) in
                            performUIUpdatesOnMain {
                                self.deckSnapshots.append(doc!)
                                self.deckTableView.insertRows(at: [IndexPath(row: (self.deckSnapshots.count)-1, section: 1)], with: .automatic)
                            }
                        })
                        
                        count += 1
                    }
                    
                    
                }
            }
        }

        
    }
    
    func addListeners(){
        getUserListSnapshot(defaultStore: defaultStore!).addSnapshotListener({ (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                print("Error fetching updates")
                return
            }
            snapshot.documentChanges.forEach({ (diff) in
                let a = diff.document.data()
                let docref = a[Constants.SnapshotFields.ref] as! DocumentReference
                
                
                    docref.getDocument(completion: { (doc, err) in
                        performUIUpdatesOnMain {
                            if diff.type == .added {
                                
                            
                                self.deckSnapshots.append(doc!)
                                self.deckTableView.insertRows(at: [IndexPath(row: (self.deckSnapshots.count)-1, section: 1)], with: .automatic)
                            }
                            if diff.type == .modified {
                                let ind = self.findDocument(doc: doc!)
                                self.deckSnapshots[ind] = doc!
                                self.deckTableView.reloadRows(at: [IndexPath(row: ind, section : 1 )], with: .automatic)
                                
                            }
                            if diff.type == .removed {
                                let ind = self.findDocument(doc: doc!)
                                self.deckSnapshots.remove(at: ind)
                                
                                self.deckTableView.deleteRows(at: [IndexPath(row: ind, section : 1 )], with: .automatic)
                                
                            }
                            
                        }
                    })
              
            })
        })
    }
    
    func findDocument(doc : DocumentSnapshot)->Int{
        var ind : Int = 0
        for deck in deckSnapshots {
            if deck.documentID == doc.documentID{
                print(ind)
                return ind
            }
            ind += 1
            
        }
        return -1
        
    }

}

extension MyDecksController{
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.SegueIdentifiers.deckDetails {
            let dest = segue.destination as! DeckViewController
            if selDeck != nil{
                dest.deck = selDeck
                selDeck = nil
            }
            if selSnap != nil{
                dest.deckDocument = selSnap
                selSnap = nil
            }
        }
    }
    
}

extension MyDecksController : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section){
            case 0:
                return "Local Decks"
            case 1:
                return "Public Decks"
            default:
                return "Decks"
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        switch indexPath.section {
        case 0:
            selDeck = decks[indexPath.row]
            break
        case 1:
            selSnap = deckSnapshots[indexPath.row]
            break
        default:
            print("Item Selected")
        }
        performSegue(withIdentifier: Constants.SegueIdentifiers.deckDetails, sender: self)

        
        print(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return decks.count
        case 1:
            return deckSnapshots.count
        default:
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: DeckTableViewCell! = tableView.dequeueReusableCell(withIdentifier: "deckCell", for: indexPath) as! DeckTableViewCell
        switch indexPath.section {
        case 0:
            let deck = decks[indexPath.row]
            
            cell.cover.image = UIImage(data: deck.cover! as Data)
            cell.title.text = deck.name
        case 1:
            let deckDoc = deckSnapshots[indexPath.row]
            let deck = deckDoc.data() as! [String:String]
            cell.title.text = deck[Constants.SnapshotFields.title]
            cell.cover.image = UIImage(named: "Red Circle")
        default:
            print("cell")
        }
        
        
        
        return cell!
    }
    
    
}

extension MyDecksController {
    
    func subscribeToNotification(_ name: NSNotification.Name, selector: Selector, object : Any? = nil ) {
        NotificationCenter.default.addObserver(self, selector: selector, name: name, object: object)
    }
    
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func managedObjectContextObjectsDidChange(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        if let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>, inserts.count > 0 {
        
            for insert in inserts{
                if insert is Deck {
                    let deck = insert as! Deck
                    self.decks.append(deck)
                    deckTableView.insertRows(at: [IndexPath(row : (self.decks.count) - 1, section : 0)], with: UITableViewRowAnimation.automatic)
                }
            
            }
        
            print("Inserted \(inserts.count)")
        
        }
        
        if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>, updates.count > 0 {
            print("Updated \(updates.count)")
        }
        
        if let deletes = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>, deletes.count > 0 {
            print("Deleted \(deletes.count)")
        }
    }
  
}
