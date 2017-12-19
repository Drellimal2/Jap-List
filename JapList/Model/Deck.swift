//
//  Deck+CoreDataClass.swift
//  JapList
//
//  Created by Dane Miller on 12/18/17.
//  Copyright © 2017 Dane Miller. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Deck)
public class Deck: NSManagedObject {
    convenience init(cover: Data, title : String = "list", context: NSManagedObjectContext) {
        
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entity(forEntityName: "Deck", in: context) {
            self.init(entity: ent, insertInto: context)
            self.cover = cover as NSData
            self.name = title
            self.createdDate = Date() as NSDate
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}
