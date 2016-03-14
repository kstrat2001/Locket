//
//  UserLocketEntity.swift
//  Locket
//
//  Created by Kain Osterholt on 3/13/16.
//  Copyright © 2016 James Frost. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class UserLocketEntity: NSManagedObject {
    
    class func createWithData(data: NSDictionary) -> UserLocketEntity {
        
        let skinData = data["locket"] as! NSDictionary
        let locketSkin : LocketSkinEntity?
        
        if skinData["title"] as! String == "default" {
            // if this is the default locket then we want to use the
            // default skin which is always the first skin in data manager
            locketSkin = DataManager.sharedManager.locketSkins[0]
        } else {
            locketSkin = LocketSkinEntity.createWithData(skinData)
        }
        
        let image = ImageAssetEntity.createWithData(data["image"] as! NSDictionary)
        let bg_color = ColorEntity.createWithData(data["bg_color"] as! NSDictionary)
        let cap_color = ColorEntity.createWithData(data["caption_color"] as! NSDictionary)
        
        let entity : UserLocketEntity = NSEntityDescription.insertNewObjectForEntityForName("UserLocketEntity", inManagedObjectContext: DataManager.sharedManager.managedObjectContext) as! UserLocketEntity
        
        entity.title = data["title"] as! String
        entity.locket_skin = locketSkin!
        entity.image = image
        entity.background_color = bg_color
        entity.caption_color = cap_color
        entity.caption_font = data["caption_font"] as! String
        entity.caption_text = data["caption_text"] as! String
        
        do {
            try DataManager.sharedManager.managedObjectContext.save()
        } catch {
            print( "error saving UserLocketEntity, error \(error)" )
        }
        
        return entity
    }
    
    func getImageFrame() -> CGRect
    {
        let pos = self.locket_skin.getAnchoredImagePosition(image.frame.origin)
        return CGRectMake(pos.x, pos.y, image.frame.width, image.frame.height)
    }
    
    class func fetchAll() -> [UserLocketEntity]
    {
        let result = DataManager.sharedManager.fetchAll("UserLocketEntity")
        
        return result as! [UserLocketEntity]
    }

}
