//
//  LocketSkinEntity.swift
//  Locket
//
//  Created by Kain Osterholt on 3/13/16.
//  Copyright © 2016 James Frost. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class LocketSkinEntity: NSManagedObject {

    class func createWithData(data: NSDictionary) -> LocketSkinEntity
    {
        let open_image = ImageAssetEntity.createWithData(data["open_image"] as! NSDictionary)
        let closed_image = ImageAssetEntity.createWithData(data["closed_image"] as! NSDictionary)
        let chain_image = ImageAssetEntity.createWithData(data["chain_image"] as! NSDictionary)
        let mask_image = ImageAssetEntity.createWithData(data["mask_image"] as! NSDictionary)
        
        let id = data["id"] as? NSNumber
        
        let formatter = NSDateFormatter();
        formatter.dateFormat = gServerDateFormat
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        formatter.timeZone = NSTimeZone.defaultTimeZone()
        
        let dateStr = (data["updated_at"] as? String)!
        let updatedDate = formatter.dateFromString(dateStr);

        let entities = DataManager.sharedManager.fetchWithId("LocketSkinEntity", id: id!)
        
        var entity : LocketSkinEntity
        
        if entities.count > 0 {
            entity = entities[0] as! LocketSkinEntity
            if entity.updated_at.compare(updatedDate!) != NSComparisonResult.OrderedAscending {
                // The updated date is not more recent.  We should not update this record
                return entity;
            }
        } else {
            entity = NSEntityDescription.insertNewObjectForEntityForName("LocketSkinEntity", inManagedObjectContext: DataManager.sharedManager.managedObjectContext) as! LocketSkinEntity
        }
        
        entity.id = id
        entity.title = data["title"] as? String
        entity.updated_at = updatedDate!
        entity.open_image = open_image
        entity.closed_image = closed_image
        entity.chain_image = chain_image
        entity.mask_image = mask_image
        
        do {
            try DataManager.sharedManager.managedObjectContext.save()
        }
        catch {
            print("error saving Locket Skin record, error: \(error)")
        }
        
        return entity
    }
    
    func getClosedLocketPosition() -> CGPoint
    {
        let width = UIScreen.mainScreen().bounds.size.width
        let height = UIScreen.mainScreen().bounds.size.height
        
        let x = 0.5 * (width - self.closed_image.frame.size.width)
        let y = 0.5 * (height - self.closed_image.frame.size.height)
        
        return CGPoint( x: x, y: y )
    }
    
    func getChainPosition() -> CGPoint
    {
        return getAnchoredImagePosition(self.chain_image.frame.origin)
    }
    
    func getOpenLocketPosition() -> CGPoint
    {
        return getAnchoredImagePosition(self.open_image.frame.origin)
    }
    
    func getMaskFrame() -> CGRect
    {
        let pos = getAnchoredImagePosition(self.mask_image.frame.origin)
        let size = self.mask_image.frame.size
        
        return CGRectMake(pos.x, pos.y, size.width, size.height)
    }
    
    func getAnchoredImagePosition(anchor: CGPoint) -> CGPoint
    {
        let locketPos : CGPoint = getClosedLocketPosition()
        let locketAnchor : CGPoint = closed_image.frame.origin
        
        let pos : CGPoint = CGPoint( x: locketPos.x + locketAnchor.x - anchor.x, y: locketPos.y + locketAnchor.y - anchor.y )
        
        return pos
    }
}
