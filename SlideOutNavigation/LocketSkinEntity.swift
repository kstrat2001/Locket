//
//  LocketSkinEntity.swift
//  Locket
//
//  Created by Kain Osterholt on 3/13/16.
//  Copyright © 2016 Kain Osterholt. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class LocketSkinEntity: NSManagedObject {

    class func createWithData(_ data: NSDictionary) -> LocketSkinEntity
    {
        let locketSkinTitleStr = data["title"] as! String
        print("loading locket skin: \(locketSkinTitleStr)")
        
        print("loading image assets for skin: \(locketSkinTitleStr)")
        let open_image = ImageAssetEntity.createWithData(data["open_image"] as! NSDictionary)
        let closed_image = ImageAssetEntity.createWithData(data["closed_image"] as! NSDictionary)
        let chain_image = ImageAssetEntity.createWithData(data["chain_image"] as! NSDictionary)
        let mask_image = ImageAssetEntity.createWithData(data["mask_image"] as! NSDictionary)
        
        let id = data["id"] as? NSNumber
        
        let formatter = DateFormatter();
        formatter.dateFormat = gServerDateFormat
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeZone = TimeZone(identifier: "UTC")
        
        let dateStr = (data["updated_at"] as? String)!
        let updatedDate = formatter.date(from: dateStr);

        let entities = DataManager.sharedManager.fetchWithId("LocketSkinEntity", id: id!)
    
        var entity : LocketSkinEntity
        
        if entities.count > 0 {
            entity = entities[0] as! LocketSkinEntity
            let savedDateStr = formatter.string(from: entity.updated_at as Date)
            print("entity exists with updated date: \(savedDateStr)")
            print("downloaded model has date:\(dateStr)")
            if entity.updated_at.compare(updatedDate!) != ComparisonResult.orderedAscending {
                // The updated date is not more recent.  We should not update this record
                print("saved entity is up to date. returning...")
                return entity;
            }
        } else {
            entity = NSEntityDescription.insertNewObject(forEntityName: "LocketSkinEntity", into: DataManager.sharedManager.managedObjectContext) as! LocketSkinEntity
        }
        
        entity.open_image = open_image
        entity.closed_image = closed_image
        entity.chain_image = chain_image
        entity.mask_image = mask_image
        
        entity.id = id
        entity.title = data["title"] as? String
        entity.updated_at = updatedDate!
        
        print(entity.title)
        
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
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        
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
        
        return CGRect(x: pos.x, y: pos.y, width: size.width, height: size.height)
    }
    
    func getAnchoredImagePosition(_ anchor: CGPoint) -> CGPoint
    {
        let locketPos : CGPoint = getClosedLocketPosition()
        let locketAnchor : CGPoint = closed_image.frame.origin
        
        let pos : CGPoint = CGPoint( x: locketPos.x + locketAnchor.x - anchor.x, y: locketPos.y + locketAnchor.y - anchor.y )
        
        return pos
    }
}
