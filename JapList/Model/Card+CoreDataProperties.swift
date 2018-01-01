//
//  Card+CoreDataProperties.swift
//  JapList
//
//  Created by Dane Miller on 12/31/17.
//  Copyright © 2017 Dane Miller. All rights reserved.
//
//

import Foundation
import CoreData


extension Card {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Card> {
        return NSFetchRequest<Card>(entityName: "Card")
    }

    @NSManaged public var kana: String?
    @NSManaged public var kanji: String?
    @NSManaged public var romaji: String?
    @NSManaged public var translation: String?
    @NSManaged public var deck: Deck?

}
