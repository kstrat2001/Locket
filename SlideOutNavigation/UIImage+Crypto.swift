//
//  UIImage+Hashing.swift
//  Locket
//
//  Created by Kain Osterholt on 3/21/16.
//  Copyright © 2016 James Frost. All rights reserved.
//

import Foundation
import CryptoSwift
import UIKit

extension UIImage {
    
    func getUniqueString() -> String {
        /*
        let imageData = UIImagePNGRepresentation(self)!
        let buffer_length = imageData.length < gMaxCryptoBufferLength ? imageData.length : gMaxCryptoBufferLength
        var image_buffer = [UInt8](count: buffer_length, repeatedValue: 0)
        imageData.getBytes(&image_buffer, length: buffer_length)
        
        return NSData.withBytes(Hash.md5(image_buffer).calculate()).toHexString()
        */
        return "\(rand())"
    }
}
