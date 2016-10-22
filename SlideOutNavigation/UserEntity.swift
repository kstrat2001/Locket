//
//  UserEntity.swift
//  Locket
//
//  Created by Kain Osterholt on 5/7/16.
//  Copyright © 2016 Kain Osterholt. All rights reserved.
//

import Foundation
import CoreData


class UserEntity: NSManagedObject {

    class func fetch() -> UserEntity?
    {
        let result = DataManager.sharedManager.fetchAll("UserEntity")
        
        if result.count == 0 {
            return nil
        } else {
            return result[0] as? UserEntity
        }
    }
    
    class func create() -> UserEntity {
        
        if UserEntity.fetch() != nil { assert(false) }
        
        let entity = NSEntityDescription.insertNewObject(forEntityName: "UserEntity", into: DataManager.sharedManager.managedObjectContext) as! UserEntity
        
        return entity
    }

}
