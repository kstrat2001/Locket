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
        return CGRect(x: CGFloat(self.anchor_x), y: CGFloat(self.anchor_y), width: CGFloat(self.width), height: CGFloat(self.height))
    }
    
    var imageURL : URL {
        return URL(string: self.image_full)!
    }
    
    var thumbURL : URL {
        return URL(string: self.image_thumb)!
    }
    
    class func createWithData(_ data: NSDictionary) -> ImageAssetEntity {
        
        let entityTitleStr = data["title"] as! String
        let id = data["id"] as? NSNumber
        print("Creating ImageAssetEntity \(entityTitleStr) with id: \(id)")
        
        let formatter = DateFormatter();
        formatter.dateFormat = gServerDateFormat
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeZone = TimeZone.current
        
        let dateStr = (data["updated_at"] as? String)!
        let updatedDate = formatter.date(from: dateStr);
        
        let entities = DataManager.sharedManager.fetchWithId("ImageAssetEntity", id: id!)
        
        var entity : ImageAssetEntity
        
        // If the id is -1 which is the default image we want to make sure
        // to create a new record instead of re-using the same entity
        if id != -1 && entities.count > 0 {
            entity = entities[0] as! ImageAssetEntity
            let entityDateStr = formatter.string(from: entity.updated_at as Date)
            print("saved entity has last updated date: \(entityDateStr)")
            if entity.updated_at.compare(updatedDate!) != ComparisonResult.orderedAscending {
                // The updated date is not more recent.  We should not update this record
                print("saved entity is up to date. returning...")
                return entity;
            }
        } else {
            entity = NSEntityDescription.insertNewObject(forEntityName: "ImageAssetEntity", into: DataManager.sharedManager.managedObjectContext) as! ImageAssetEntity
        }
        
        let screenWidth : Float = Float(UIScreen.main.bounds.width)
        let scaleFactor : Float = screenWidth / 1242
        let width: NSNumber = NSNumber(value: scaleFactor * (data["width"] as! Float) as Float)
        let height: NSNumber = NSNumber(value: scaleFactor * (data["height"] as! Float) as Float)
        let anchorX: NSNumber = NSNumber(value: scaleFactor * (data["anchor_x"] as! Float) as Float)
        let anchorY: NSNumber = NSNumber(value: scaleFactor * (data["anchor_y"] as! Float) as Float)
        
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
        if entity.image_full.contains(gMainBundleHost) == false &&
            entity.image_full.contains(gFileHost) == false &&
            id != -1 {
            DataManager.sharedManager.deleteCachedFile(URL(string: entity.image_full)!)
            DataManager.sharedManager.deleteCachedFile(URL(string: entity.image_thumb)!)
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
