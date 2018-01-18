//
//  CardReviewFlowLayout.swift
//  JapList
//
//  Created by Dane Miller on 1/18/18.
//  Copyright © 2018 Dane Miller. All rights reserved.
//

import UIKit

class CardReviewFlowLayout: UICollectionViewFlowLayout {
    
        var mostRecentOffset : CGPoint = CGPoint()
        
        override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
            
            if velocity.x == 0 {
                return mostRecentOffset
            }
            
            if let cv = self.collectionView {
                
                let cvBounds = cv.bounds
                let halfWidth = cvBounds.size.width * 0.5;
                
                
                if let attributesForVisibleCells = self.layoutAttributesForElements(in: cvBounds) {
                    
                    var candidateAttributes : UICollectionViewLayoutAttributes?
                    for attributes in attributesForVisibleCells {
                        
                        // == Skip comparison with non-cell items (headers and footers) == //
                        if attributes.representedElementCategory != UICollectionElementCategory.cell {
                            continue
                        }
                        
                        if (attributes.center.x == 0) || (attributes.center.x > (cv.contentOffset.x + halfWidth) && velocity.x < 0) {
                            continue
                        }
                        candidateAttributes = attributes
                    }
                    
                    // Beautification step , I don't know why it works!
                    if(proposedContentOffset.x == -(cv.contentInset.left)) {
                        return proposedContentOffset
                    }
                    
                    guard let _ = candidateAttributes else {
                        return mostRecentOffset
                    }
                    mostRecentOffset = CGPoint(x: floor(candidateAttributes!.center.x - halfWidth), y: proposedContentOffset.y)
                    return mostRecentOffset
                    
                }
            }
            
            // fallback
            mostRecentOffset = super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
            return mostRecentOffset
        }
        
        
    
}

