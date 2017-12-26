//
//  DataUtils.swift
//  JapList
//
//  Created by Dane Miller on 12/21/17.
//  Copyright © 2017 Dane Miller. All rights reserved.
//

import Foundation
import CoreData

func getAllDecks(_ predicate : NSPredicate? = nil, moc : NSManagedObjectContext) -> [Deck]{
    let decksFetch : NSFetchRequest<Deck> = Deck.fetchRequest()
    if let pred = predicate{
        decksFetch.predicate = pred
    }
    
    do {
        let fetchedDecks = try moc.fetch(decksFetch)
        return fetchedDecks
        
    } catch {
        fatalError("Failed to fetch employees: \(error)")
    }
    
}


