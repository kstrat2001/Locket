//
//  UIImage+Hashing.swift
//  Locket
//
//  Created by Kain Osterholt on 3/21/16.
//  Copyright © 2016 James Frost. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    func getUniqueString() -> String {
        let user = SettingsManager.sharedManager.user
        let imageNumber = user.photo_index
        
        // increment the photo number so that the stored value is unique
        user.photo_index = NSNumber(int: user.photo_index.intValue + 1)
        DataManager.sharedManager.saveAllRecords()
        
        return "locket_user_photo_\(imageNumber)"
    }
}
