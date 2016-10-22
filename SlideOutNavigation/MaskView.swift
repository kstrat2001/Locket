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
    fileprivate (set) var maskViewImage : UIImage?
    var mask: CGImage?
    
    fileprivate (set) var whiteFullScreenImage: UIImage?
    fileprivate (set) var blackFullScreenImage: UIImage?
    
    fileprivate (set) var inverseMask: CGImage?
    fileprivate (set) var inverseMaskView: UIView?
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        inverseMaskView = UIView(frame: frame)
        inverseMaskView?.isUserInteractionEnabled = false
        
        let colorView = UIView(frame: frame)
        colorView.backgroundColor = UIColor.white
        whiteFullScreenImage = colorView.captureImage()
        
        colorView.backgroundColor = UIColor.black
        blackFullScreenImage = colorView.captureImage()
        
        // Set up the background to mask transparent
        // Any color added to the view will mask in image data
        self.backgroundColor = UIColor.white
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
        inverseMaskView?.isUserInteractionEnabled = false
        
        let whiteMaskPatternImageView = UIImageView(image: whiteMaskPattern)
        whiteMaskPatternImageView.frame = self.frame
        inverseMaskView?.addSubview(whiteMaskPatternImageView)
        inverseMaskView?.backgroundColor = UIColor(white: 0.5, alpha: 1.0)
        let inverseMaskImage = inverseMaskView?.captureImage()
        self.inverseMask = createMask(inverseMaskImage!)
        
        // No longer need the white pattern
        whiteMaskPatternImageView.removeFromSuperview()

        let blackOverlay = UIImage(cgImage: (blackFullScreenImage!.cgImage?.masking(self.inverseMask!)!)!)
        inverseMaskView?.backgroundColor = UIColor.clear
        let blackOverlayView = UIImageView(image: blackOverlay)
        blackOverlayView.frame = self.frame
        inverseMaskView?.addSubview(blackOverlayView)
    }
    
    func applyMaskToImage(_ image: UIImage) -> UIImage
    {
        return UIImage(cgImage: image.cgImage!.masking(self.mask!)!)
    }
    
    fileprivate func createMask(_ image: UIImage) -> CGImage
    {
        let maskRef = image.cgImage
        let mask = CGImage(maskWidth: (maskRef?.width)!,
            height: (maskRef?.height)!,
            bitsPerComponent: (maskRef?.bitsPerComponent)!,
            bitsPerPixel: (maskRef?.bitsPerPixel)!,
            bytesPerRow: (maskRef?.bytesPerRow)!,
            provider: (maskRef?.dataProvider!)!, decode: nil, shouldInterpolate: false);
        
        return mask!
    }
}
