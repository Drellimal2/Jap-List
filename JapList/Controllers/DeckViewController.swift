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
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var wordTable: UITableView!
    @IBOutlet weak var newWordBtn: UIButton!
    @IBOutlet weak var reviewBtn: UIButton!
    @IBOutlet weak var quizBtn: UIButton!
    @IBOutlet weak var otherBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stack = delegate.stack
        setup()
        subscribeToNotification(.NSManagedObjectContextObjectsDidChange, selector: #selector(managedObjectContextObjectsDidChange), object: stack?.context, controller: self)        // Do any
    }

    func setup(){
        titleLabel.text = deck?.name
        coverImage.image = UIImage(data: (deck?.cover)! as Data)
        descTextView.text = deck?.description
        cards = Array((deck?.cards)!) as? [Card]

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
        return (cards?.count)!
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: CardTableViewCell! = tableView.dequeueReusableCell(withIdentifier: "cardTableCell", for: indexPath) as! CardTableViewCell
        
        let card = cards![indexPath.row]
        cell.kanjiLabel.text = card.kanji
        cell.kanaLabel.text = card.kana
        cell.translationLabel.text = card.translation
        
        
        
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
