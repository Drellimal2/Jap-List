//
//  CardReviewViewController.swift
//  JapList
//
//  Created by Dane Miller on 12/31/17.
//  Copyright © 2017 Dane Miller. All rights reserved.
//

import UIKit
import Firebase

class CardReviewViewController: UIViewController {

    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var cardsCollectionView: UICollectionView!
    
    var deck : Deck? = nil
    var cards : [Card]? = nil
    var deckDocument : DocumentSnapshot? = nil
    var cardSnapshots : [DocumentSnapshot]? = nil
    var isSnap :Bool? = false
    var cellWidth : CGFloat?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFlowLayout()
        setup()
        
        progressView.progress = 0.0
    }

    func setup(){
        if deck == nil && deckDocument != nil{
            isSnap = true
            if cardSnapshots?.count == 0 {
                alert(title: "No Cards", message: "No cards to review. You will now be redirected back.", controller: self)
                dismiss(animated: true, completion: nil)
            }
            return
        } else if deck != nil && deckDocument == nil{
            isSnap = false
            if cards?.count == 0 {
                alert(title: "No Cards", message: "No cards to review. You will now be redirected back.", controller: self)
                dismiss(animated: true, completion: nil)
            }
            return
        } else {
            alert(title: "Error", message: "Error loading deck", controller: self)
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func xAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func setupFlowLayout(){
        let space:CGFloat = 8.0
        let dimension = (cardsCollectionView.frame.size.width - (2 * space))
        cellWidth = dimension
        let height = cardsCollectionView.frame.size.height - (2 * space)
        flowLayout.minimumInteritemSpacing = space * 2
        flowLayout.minimumLineSpacing = space * 2
        flowLayout.itemSize = CGSize(width: dimension, height: height )
        flowLayout.scrollDirection = .horizontal
    }
    
}

extension CardReviewViewController : UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isSnap! {
            return (cardSnapshots?.count)!
        } else{
            return (cards?.count)!
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.StoryboardIdentifiers.detailCardView, for: indexPath) as! CardReviewCollectionViewCell
        cellSetup(cell: cell)
        var kana : String? = ""
        var trans : String? = ""
        var kanji : String? = ""
        if isSnap! {
            let cardSnapshot = cardSnapshots![indexPath.row].data() as! [String: String]
            trans = cardSnapshot[Constants.SnapshotFields.trans]
            kanji = cardSnapshot[Constants.SnapshotFields.kanji] ?? ""
            kana = cardSnapshot[Constants.SnapshotFields.kana] ?? ""
            
            
        } else{
            let card = cards![indexPath.row]
            trans =  card.translation
            kanji = card.kanji ?? ""
            kana = card.kana ?? ""
            
        }
        cell.kanjiLabel.isHidden = (kanji?.isEmpty)!
        cell.kanaLabel.isHidden = (kana?.isEmpty)!
        cell.transLabel.text = trans
        cell.kanjiLabel.text = kanji
        cell.kanaLabel.text = kana
        return cell
        
    }
    
    func cellSetup(cell : CardReviewCollectionViewCell, front : Bool = true){
        cell.isFlipped = !front
        cell.japStackView.isHidden =  !front
        cell.transLabel.isHidden = front
        cell.kanjiLabel.isHidden = !front
        cell.kanaLabel.isHidden = !front
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let cell = collectionView.cellForItem(at: indexPath) as! CardReviewCollectionViewCell
        flipCard(cell: cell)
    }
    
    
    
    func flipCard(cell : CardReviewCollectionViewCell){
        let transitionOptions = UIViewAnimationOptions.transitionFlipFromLeft
        UIView.transition(with: cell.contentView, duration: 0.5, options: transitionOptions, animations: {
            
            cell.japStackView.isHidden = !cell.isFlipped
            cell.transLabel.isHidden = cell.isFlipped
            cell.isFlipped = !cell.isFlipped
        }) { (finished) in
            print("We did it")
        }
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let indexPaths = cardsCollectionView.indexPathsForVisibleItems
        if indexPaths.count == 1 {
            let index = indexPaths[0].row
            progressView.progress = Float(index / cardsCollectionView.numberOfItems(inSection: 0))
        }
        print("calc")
    }
    

    
}