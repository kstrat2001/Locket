//
//  ImageAssetEntity+CoreDataProperties.swift
//  Locket
//
//  Created by Kain Osterholt on 3/13/16.
//  Copyright © 2016 James Frost. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension ImageAssetEntity {

    @NSManaged var anchor_x: NSNumber!
    @NSManaged var anchor_y: NSNumber!
    @NSManaged var height: NSNumber!
    @NSManaged var image_full: String!
    @NSManaged var image_thumb: String!
    @NSManaged var title: String!
    @NSManaged var id: NSNumber!
    @NSManaged var orientation: NSNumber!
    @NSManaged var updated_at: NSDate!
    @NSManaged var width: NSNumber!
    @NSManaged var closed_image_owner: LocketSkinEntity?
    @NSManaged var user_locket_image: UserLocketEntity?
    @NSManaged var open_image_owner: LocketSkinEntity?
    @NSManaged var chain_image_owner: LocketSkinEntity?
    @NSManaged var mask_image_owner: LocketSkinEntity?

}
