//
//  ColorEntity+CoreDataProperties.swift
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

extension ColorEntity {

    @NSManaged var alpha: NSNumber!
    @NSManaged var blue: NSNumber!
    @NSManaged var green: NSNumber!
    @NSManaged var red: NSNumber!
    @NSManaged var bg_color_owner: UserLocketEntity?
    @NSManaged var caption_color_owner: UserLocketEntity?

}
