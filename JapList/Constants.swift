//
//  Constants.swift
//  JapList
//
//  Created by Dane Miller on 12/18/17.
//  Copyright © 2017 Dane Miller. All rights reserved.
//

import Foundation
import UIKit

struct Constants{
    
    static let grey_color = UIColor(red: 200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 0.5)

    
    struct SegueIdentifiers{
        
        static let newDeck = "newDeck"
        static let newCard = "newCard"
        static let deckDetails = "deckDetails"
        static let cardReview = "reviewCards"
        static let editDeck = "editDeck"
        
        
        
    }
    
    struct StoryboardIdentifiers{
        
        static let detailCardView = "detailViewCard"
        
        static let cardRow = "cardTableCell"
        
    }
    
    struct SnapshotFields {
        // Deck
        static let title = "title"
        static let desc = "description"
        static let cover = "cover_url"
        
        // Card
        static let kanji = "kanji"
        static let kana = "kana"
        static let trans = "translation"
        static let romaji = "romaji"
        
        static let ref = "reference"
        static let coredataref = "core_data_ref"
        
        
        
    }
    
    
    struct TextLengths {
        
        static let kanji = 40
        static let kana = 40
        static let trans = 60
        static let title = 30
        static let desc = 100
    }
    
    
    struct UserDefaultKeys {
        
        static let firstTime  = "firstTime"
        static let firstDeck = "firstDeck"
        static let firstReview = "firstReview"
        static let firstCard = "firstCard"
        static let firstDeckDetails = "firstDeckDetails"
    }
    
    
    
    
    
    
}
