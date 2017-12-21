//
//  MyDecksController.swift
//  JapList
//
//  Created by Dane Miller on 12/18/17.
//  Copyright © 2017 Dane Miller. All rights reserved.
//

import UIKit
import CoreData


class MyDecksController: UIViewController {

    @IBOutlet weak var deckTableView: UITableView!
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var stack : CoreDataStack? = nil

    var decks : [Deck] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stack = delegate.stack
        subscribeToNotification(.NSManagedObjectContextObjectsDidChange, selector: #selector(managedObjectContextObjectsDidChange), object: stack?.context)        // Do any additional setup after loading the view.
    }

    @IBAction func addDeck(_ sender: Any) {
        performSegue(withIdentifier: Constants.SegueIdentifiers.newDeck, sender: self)
    }
    

}

extension MyDecksController : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        print(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return decks.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: DeckTableViewCell! = tableView.dequeueReusableCell(withIdentifier: "deckCell", for: indexPath) as! DeckTableViewCell
        
        let deck = decks[indexPath.row]
        cell.cover.image = UIImage(data: deck.cover! as Data)
        cell.title.text = deck.name
        
        
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
