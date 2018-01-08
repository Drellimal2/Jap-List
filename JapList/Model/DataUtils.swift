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

func updateLocalDeck(deck :Deck, title: String?,desc : String?, cover : Data, stack : CoreDataStack){
    
    DispatchQueue.main.async {
        stack.performBackgroundBatchOperation{
            (workingContext) in
            let newdeck = workingContext.object(with: deck.objectID) as! Deck
            newdeck.name = title
            newdeck.desc = desc
            newdeck.cover = cover as NSData
            
        }
    }
    
}

func newCard(deck :Deck, kanji: String?,trans : String?, kana : String?, stack : CoreDataStack){
    
    DispatchQueue.main.async {
        stack.performBackgroundBatchOperation{
            (workingContext) in
            let newdeck = workingContext.object(with: deck.objectID) as! Deck
            let newcard = Card(kana: kana!, kanji: kanji!, romaji: "", translation: trans!, context: workingContext)
            newcard.deck = newdeck
            
        }
    }
    
}

func getObjectIdUniqueString(obj : NSManagedObject)->String{
    return String(((obj as! Deck).createdDate?.timeIntervalSince1970)!)
//    return obj.objectID.uriRepresentation().pathComponents[obj.objectID.uriRepresentation().pathComponents.count - 1]
}




