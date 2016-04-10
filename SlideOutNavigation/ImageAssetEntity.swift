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

        
        let screenWidth : Float = Float(UIScreen.mainScreen().bounds.width)
        let scaleFactor : Float = screenWidth / 1242
        let width: NSNumber = NSNumber(float: scaleFactor * (data["width"] as! Float))
        let height: NSNumber = NSNumber(float: scaleFactor * (data["height"] as! Float))
        let anchorX: NSNumber = NSNumber(float: scaleFactor * (data["anchor_x"] as! Float))
        let anchorY: NSNumber = NSNumber(float: scaleFactor * (data["anchor_y"] as! Float))
        
        let id = data["id"] as? NSNumber
        
        let formatter = NSDateFormatter();
        formatter.dateFormat = gServerDateFormat
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        formatter.timeZone = NSTimeZone.defaultTimeZone()
        
        let dateStr = (data["updated_at"] as? String)!
        let updatedDate = formatter.dateFromString(dateStr);
        
        let entities = DataManager.sharedManager.fetchWithId("ImageAssetEntity", id: id!)
        
        var entity : ImageAssetEntity
        
        if entities.count > 0 {
            entity = entities[0] as! ImageAssetEntity
            if entity.updated_at.compare(updatedDate!) != NSComparisonResult.OrderedAscending {
                // The updated date is not more recent.  We should not update this record
                return entity;
            }
        } else {
            entity = NSEntityDescription.insertNewObjectForEntityForName("ImageAssetEntity", inManagedObjectContext: DataManager.sharedManager.managedObjectContext) as! ImageAssetEntity
        }
        
        entity.title = data["title"] as! String
        entity.id = id
        entity.updated_at = updatedDate
        entity.anchor_x = anchorX
        entity.anchor_y = anchorY
        entity.width = width
        entity.height = height
        entity.image_full = data["image_full"] as! String
        entity.image_thumb = data["image_thumb"] as! String
        
        DataManager.sharedManager.saveAllRecords()
        
        return entity
    }

}
