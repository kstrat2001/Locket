//
//  UIView+CaptureImage.swift
//  Locket
//
//  Created by Kain Osterholt on 2/26/16.
//  Copyright © 2016 James Frost. All rights reserved.
//

import Foundation
import UIKit

extension UIView
{
    func captureImage() -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.0);
        let context = UIGraphicsGetCurrentContext();
        self.layer.renderInContext(context!);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image;
    }
}