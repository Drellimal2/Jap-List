//
//  DeckViewController.swift
//  JapList
//
//  Created by Dane Miller on 12/18/17.
//  Copyright © 2017 Dane Miller. All rights reserved.
//

import UIKit

class DeckViewController: UIViewController {
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var stack : CoreDataStack? = nil
    var deck : Deck?
    var cards : [Card]?

    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var descTextView: UITextView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var wordTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stack = delegate.stack
        cards = Array((deck?.cards)!) as? [Card]
        // Do any additional setup after loading the view.
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
