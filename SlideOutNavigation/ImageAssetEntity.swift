//
//  ImageAssetEntity.swift
//  Locket
//
//  Created by Kain Osterholt on 3/13/16.
//  Copyright © 2016 James Frost. All rights reserved.
//

import Foundation
import CoreData
import UIKit


class ImageAssetEntity: NSManagedObject {
    
    var frame : CGRect! {
        return CGRectMake(CGFloat(self.anchor_x), CGFloat(self.anchor_y), CGFloat(self.width), CGFloat(self.height))
    }
    
    var imageURL : NSURL {
        return NSURL(string: self.image_full)!
    }
    
    var thumbURL : NSURL {
        return NSURL(string: self.image_thumb)!
    }
    
    class func createWithData(data: NSDictionary) -> ImageAssetEntity {
        
        let entityTitleStr = data["title"] as! String
        let id = data["id"] as? NSNumber
        print("Creating ImageAssetEntity \(entityTitleStr) with id: \(id)")
        
        let formatter = NSDateFormatter();
        formatter.dateFormat = gServerDateFormat
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        formatter.timeZone = NSTimeZone.defaultTimeZone()
        
        let dateStr = (data["updated_at"] as? String)!
        let updatedDate = formatter.dateFromString(dateStr);
        
        let entities = DataManager.sharedManager.fetchWithId("ImageAssetEntity", id: id!)
        
        var entity : ImageAssetEntity
        
        // If the id is -1 which is the default image we want to make sure
        // to create a new record instead of re-using the same entity
        if id != -1 && entities.count > 0 {
            entity = entities[0] as! ImageAssetEntity
            let entityDateStr = formatter.stringFromDate(entity.updated_at)
            print("saved entity has last updated date: \(entityDateStr)")
            if entity.updated_at.compare(updatedDate!) != NSComparisonResult.OrderedAscending {
                // The updated date is not more recent.  We should not update this record
                print("saved entity is up to date. returning...")
                return entity;
            }
        } else {
            entity = NSEntityDescription.insertNewObjectForEntityForName("ImageAssetEntity", inManagedObjectContext: DataManager.sharedManager.managedObjectContext) as! ImageAssetEntity
        }
        
        let screenWidth : Float = Float(UIScreen.mainScreen().bounds.width)
        let scaleFactor : Float = screenWidth / 1242
        let width: NSNumber = NSNumber(float: scaleFactor * (data["width"] as! Float))
        let height: NSNumber = NSNumber(float: scaleFactor * (data["height"] as! Float))
        let anchorX: NSNumber = NSNumber(float: scaleFactor * (data["anchor_x"] as! Float))
        let anchorY: NSNumber = NSNumber(float: scaleFactor * (data["anchor_y"] as! Float))
        
        entity.title = entityTitleStr
        entity.id = id
        entity.updated_at = updatedDate
        entity.anchor_x = anchorX
        entity.anchor_y = anchorY
        entity.width = width
        entity.height = height
        entity.image_full = data["image_full"] as! String
        entity.image_thumb = data["image_thumb"] as! String
        
        // If we are updating or downloading this image for the first time
        // the saved data on the device needs to be purged in order to download the new asset
        if entity.image_full.containsString(gMainBundleHost) == false &&
            entity.image_full.containsString(gFileHost) == false &&
            id != -1 {
            DataManager.sharedManager.deleteCachedFile(NSURL(string: entity.image_full)!)
            DataManager.sharedManager.deleteCachedFile(NSURL(string: entity.image_thumb)!)
        }
        
        do {
            try DataManager.sharedManager.managedObjectContext.save()
        }
        catch {
            print("error saving Image Asset record, error: \(error)")
        }
        
        return entity
    }

}
