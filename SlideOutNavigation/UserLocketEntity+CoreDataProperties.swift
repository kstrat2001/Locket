//
//  UserLocketEntity+CoreDataProperties.swift
//  Locket
//
//  Created by Kain Osterholt on 5/7/16.
//  Copyright © 2016 James Frost. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension UserLocketEntity {

    @NSManaged var caption_font: String!
    @NSManaged var caption_text: String!
    @NSManaged var title: String!
    @NSManaged var background_color: ColorEntity!
    @NSManaged var caption_color: ColorEntity!
    @NSManaged var image: ImageAssetEntity!
    @NSManaged var locket_skin: LocketSkinEntity!
    @NSManaged var user: UserEntity?

}
