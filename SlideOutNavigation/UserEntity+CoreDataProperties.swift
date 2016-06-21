//
//  UserEntity+CoreDataProperties.swift
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

extension UserEntity {

    @NSManaged var photo_index: NSNumber!
    @NSManaged var selected_locket: UserLocketEntity?

}
