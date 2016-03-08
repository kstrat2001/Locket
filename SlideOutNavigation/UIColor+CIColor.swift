//
//  UIColor+CIColor.swift
//  Locket
//
//  Created by Kain Osterholt on 3/7/16.
//  Copyright © 2016 James Frost. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    var coreImageColor: CoreImage.CIColor? {
        return CoreImage.CIColor(color: self)  // The resulting Core Image color, or nil
    }
}