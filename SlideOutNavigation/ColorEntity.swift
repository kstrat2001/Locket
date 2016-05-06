//
//  ColorEntity.swift
//  Locket
//
//  Created by Kain Osterholt on 3/13/16.
//  Copyright © 2016 James Frost. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class ColorEntity: NSManagedObject {
    
    var uicolor : UIColor {
        return UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
    }
    
    var inverse : UIColor {
        return UIColor(red: CGFloat(1.0 - CGFloat(red)), green: CGFloat(1.0 - CGFloat(green)), blue: CGFloat(1.0 - CGFloat(blue)), alpha: CGFloat(alpha))
    }
    
    class func createWithData(data: NSDictionary) -> ColorEntity
    {
        let entity : ColorEntity = NSEntityDescription.insertNewObjectForEntityForName("ColorEntity", inManagedObjectContext: DataManager.sharedManager.managedObjectContext) as! ColorEntity
        
        entity.red = NSNumber(float: data["red"] as! Float)
        entity.green = NSNumber(float: data["green"] as! Float)
        entity.blue = NSNumber(float: data["blue"] as! Float)
        entity.alpha = NSNumber(float: data["alpha"] as! Float)
        
        do {
            try DataManager.sharedManager.managedObjectContext.save()
        }
        catch {
            print("error saving ColorEntity record, error: \(error)")
        }
        
        return entity
    }

}
