//
//  UIView+LoadFromNIB.swift
//  Locket
//
//  Created by Kain Osterholt on 2/29/16.
//  Copyright © 2016 Kain Osterholt. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    class func loadFromNibNamed(_ nibNamed: String, bundle : Bundle? = nil) -> UIView? {
        return UINib(
            nibName: nibNamed,
            bundle: bundle
            ).instantiate(withOwner: nil, options: nil)[0] as? UIView
    }
}
