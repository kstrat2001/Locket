//
//  UIView+CaptureImage.swift
//  Locket
//
//  Created by Kain Osterholt on 2/26/16.
//  Copyright © 2016 Kain Osterholt. All rights reserved.
//

import Foundation
import UIKit

extension UIView
{
    func captureImage() -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0);
        let context = UIGraphicsGetCurrentContext();
        self.layer.render(in: context!);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image!;
    }
}
