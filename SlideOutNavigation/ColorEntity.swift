//
//  ColorEntity.swift
//  Locket
//
//  Created by Kain Osterholt on 3/13/16.
//  Copyright © 2016 Kain Osterholt. All rights reserved.
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
    
    class func createWithData(_ data: NSDictionary) -> ColorEntity
    {
        let entity : ColorEntity = NSEntityDescription.insertNewObject(forEntityName: "ColorEntity", into: DataManager.sharedManager.managedObjectContext) as! ColorEntity
        
        entity.red = NSNumber(value: data["red"] as! Float as Float)
        entity.green = NSNumber(value: data["green"] as! Float as Float)
        entity.blue = NSNumber(value: data["blue"] as! Float as Float)
        entity.alpha = NSNumber(value: data["alpha"] as! Float as Float)
        
        do {
            try DataManager.sharedManager.managedObjectContext.save()
        }
        catch {
            print("error saving ColorEntity record, error: \(error)")
        }
        
        return entity
    }

}
