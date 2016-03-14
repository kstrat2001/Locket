//
//  LocketSkinEntity+CoreDataProperties.swift
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

extension LocketSkinEntity {

    @NSManaged var title: String!
    @NSManaged var chain_image: ImageAssetEntity!
    @NSManaged var closed_image: ImageAssetEntity!
    @NSManaged var mask_image: ImageAssetEntity!
    @NSManaged var open_image: ImageAssetEntity!
    @NSManaged var locket_skin_owner: UserLocketEntity?

}
