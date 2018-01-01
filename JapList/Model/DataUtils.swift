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

func deleteLocalDeck(deck :Deck, stack : CoreDataStack){
    
    DispatchQueue.main.async {
        stack.performBackgroundBatchOperation{
            (workingContext) in
            let decktodelete = workingContext.object(with: deck.objectID) as! Deck
            
            workingContext.delete(decktodelete as NSManagedObject)
        }
    }
    
}

func deleteLocalCard(deck :Deck, card : Card, stack : CoreDataStack){
    
    DispatchQueue.main.async {
        stack.performBackgroundBatchOperation{
            (workingContext) in
            let newdeck = workingContext.object(with: deck.objectID) as! Deck
            let cardtodelete = workingContext.object(with: card.objectID) as! Card
            if (newdeck.cards?.contains(cardtodelete))!{
                workingContext.delete(cardtodelete as NSManagedObject)

            }
        }
    }
    
}



