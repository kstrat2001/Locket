//
//  MaskView.swift
//  Locket
//
//  Created by Kain Osterholt on 2/26/16.
//  Copyright © 2016 James Frost. All rights reserved.
//

import Foundation
import UIKit

class MaskView : UIView
{
    private (set) var maskViewImage : UIImage?
    private (set) var mask: CGImage?
    
    private (set) var whiteFullScreenImage: UIImage?
    
    private (set) var inverseMask: CGImage?
    private (set) var inverseMaskView: UIView?
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        inverseMaskView = UIView(frame: frame)
        inverseMaskView?.userInteractionEnabled = false
        
        let whiteView = UIView(frame: frame)
        whiteView.backgroundColor = UIColor.whiteColor()
        whiteFullScreenImage = whiteView.captureImage()
        
        // Set up the background to mask transparent
        // Any color added to the view will mask in image data
        self.backgroundColor = UIColor.whiteColor()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateMask()
    {
        maskViewImage = self.captureImage()
        self.mask = createMask(maskViewImage!)
        
        let whiteMaskPattern = maskImage(whiteFullScreenImage!)
        
        let whiteMaskPatternImageView = UIImageView(image: whiteMaskPattern)
        whiteMaskPatternImageView.frame = self.frame
        inverseMaskView?.addSubview(whiteMaskPatternImageView)
        inverseMaskView?.backgroundColor = UIColor(white: 0.5, alpha: 1.0)
        let inverseMaskImage = inverseMaskView?.captureImage()
        inverseMask = createMask(inverseMaskImage!)
        
        // No longer need the white pattern
        whiteMaskPatternImageView.removeFromSuperview()

        inverseMaskView?.backgroundColor = UIColor.blackColor()
        let blackImage = inverseMaskView?.captureImage()
        let blackOverlay = UIImage(CGImage: CGImageCreateWithMask(blackImage!.CGImage, self.inverseMask)!)
        inverseMaskView?.backgroundColor = UIColor.clearColor()
        let blackOverlayView = UIImageView(image: blackOverlay)
        blackOverlayView.frame = self.frame
        inverseMaskView?.addSubview(blackOverlayView)
    }
    
    func maskImage(imageToMask: UIImage) -> UIImage
    {
        return UIImage(CGImage: CGImageCreateWithMask(imageToMask.CGImage, self.mask)!)
    }
    
    private func createMask(image: UIImage) -> CGImage
    {
        let maskRef = image.CGImage
        let mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
            CGImageGetHeight(maskRef),
            CGImageGetBitsPerComponent(maskRef),
            CGImageGetBitsPerPixel(maskRef),
            CGImageGetBytesPerRow(maskRef),
            CGImageGetDataProvider(maskRef), nil, false);
        
        return mask!
    }
}