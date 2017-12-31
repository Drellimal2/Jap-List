//
//  CardReviewCollectionViewCell.swift
//  JapList
//
//  Created by Dane Miller on 12/31/17.
//  Copyright © 2017 Dane Miller. All rights reserved.
//

import UIKit

class CardReviewCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var kanaLabel: UILabel!
    @IBOutlet weak var japStackView: UIStackView!
    @IBOutlet weak var kanjiLabel: UILabel!
    @IBOutlet weak var transLabel: UILabel!
    
    var isFlipped : Bool = false
    
}
