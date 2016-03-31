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
    private (set) var blackFullScreenImage: UIImage?
    
    private (set) var inverseMask: CGImage?
    private (set) var inverseMaskView: UIView?
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        inverseMaskView = UIView(frame: frame)
        inverseMaskView?.userInteractionEnabled = false
        
        let colorView = UIView(frame: frame)
        colorView.backgroundColor = UIColor.whiteColor()
        whiteFullScreenImage = colorView.captureImage()
        
        colorView.backgroundColor = UIColor.blackColor()
        blackFullScreenImage = colorView.captureImage()
        
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
        
        let whiteMaskPattern = applyMaskToImage(whiteFullScreenImage!)
        
        // reallocate the inverseMaskView here to clear all previous subviews
        inverseMaskView = UIView(frame: frame)
        inverseMaskView?.userInteractionEnabled = false
        
        let whiteMaskPatternImageView = UIImageView(image: whiteMaskPattern)
        whiteMaskPatternImageView.frame = self.frame
        inverseMaskView?.addSubview(whiteMaskPatternImageView)
        inverseMaskView?.backgroundColor = UIColor(white: 0.5, alpha: 1.0)
        let inverseMaskImage = inverseMaskView?.captureImage()
        self.inverseMask = createMask(inverseMaskImage!)
        
        // No longer need the white pattern
        whiteMaskPatternImageView.removeFromSuperview()

        let blackOverlay = UIImage(CGImage: CGImageCreateWithMask(blackFullScreenImage!.CGImage, self.inverseMask)!)
        inverseMaskView?.backgroundColor = UIColor.clearColor()
        let blackOverlayView = UIImageView(image: blackOverlay)
        blackOverlayView.frame = self.frame
        inverseMaskView?.addSubview(blackOverlayView)
    }
    
    func applyMaskToImage(image: UIImage) -> UIImage
    {
        return UIImage(CGImage: CGImageCreateWithMask(image.CGImage, self.mask)!)
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