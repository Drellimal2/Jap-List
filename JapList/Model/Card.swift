//
//  Card+CoreDataClass.swift
//  JapList
//
//  Created by Dane Miller on 12/18/17.
//  Copyright © 2017 Dane Miller. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Card)
public class Card: NSManagedObject {
    convenience init(kana: String, kanji : String = "kanji", romaji : String = "romaji", translation : String, context: NSManagedObjectContext) {
        
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entity(forEntityName: "Card", in: context) {
            self.init(entity: ent, insertInto: context)
            self.kana = kana
            self.kanji = kanji
            self.romaji = romaji
            self.translation = translation
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}
