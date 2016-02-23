//
//  DownloadableMaskedImageView.swift
//  Locket
//
//  Created by Kain Osterholt on 2/22/16.
//  Copyright © 2016 James Frost. All rights reserved.
//

import Foundation
import UIKit

class DownloadableMaskedImageView : UIView
{
    private (set) var colorImageView : DownloadableImageView?
    private (set) var fullScreenColorImageView: UIView?

    private (set) var maskImageView : DownloadableImageView?
    private (set) var fullScreenMaskView : UIView?
    private (set) var fullScreenMaskImage : UIImage?
    
    private (set) var finalImageView : UIImageView?
    
    private (set) var colorImageLoaded : Bool = false
    private (set) var maskImageLoaded : Bool = false
    
    init(frame: CGRect, maskFrame: CGRect, colorUrl: NSURL, maskUrl: NSURL)
    {
        super.init(frame: frame)
        
        fullScreenColorImageView = UIView(frame: frame)
        
        colorImageView = DownloadableImageView(frame: CGRectMake(33, 160, 300, 233))
        colorImageView?.delegate = self
        
        fullScreenColorImageView?.addSubview(colorImageView!)
        
        fullScreenMaskView = UIView(frame: frame)
        fullScreenMaskView?.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        
        maskImageView = DownloadableImageView(frame: maskFrame)
        maskImageView?.delegate = self
        
        fullScreenMaskView?.addSubview(maskImageView!)
        
        finalImageView = UIImageView(frame: frame)
        
        colorImageView?.loadImageFromUrl(colorUrl)
        maskImageView?.loadImageFromUrl(maskUrl)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupLayers()
    {
        // Create the full screen mask image and store that for future use
        fullScreenMaskImage = captureView(fullScreenMaskView!)
        
        // Update the final image with the mask image
        self.updateFinalImage()
        self.addSubview(finalImageView!)
        
        //self.toggleEditMode()
    }
    
    private func toggleEditMode()
    {
        self.addSubview(fullScreenColorImageView!)
    }
    
    private func updateFinalImage()
    {
        let fullScreenColor = captureView(fullScreenColorImageView!)
        
        finalImageView?.image = createMaskedImage(fullScreenColor, mask: fullScreenMaskImage!)
    }
    
    private func captureView(view: UIView) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
        let context = UIGraphicsGetCurrentContext();
        view.layer.renderInContext(context!);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }
    
    private func createMaskedImage(image: UIImage, mask: UIImage) -> UIImage
    {
        let maskRef = mask.CGImage
        let mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
            CGImageGetHeight(maskRef),
            CGImageGetBitsPerComponent(maskRef),
            CGImageGetBitsPerPixel(maskRef),
            CGImageGetBytesPerRow(maskRef),
            CGImageGetDataProvider(maskRef), nil, false);
        
        let masked = CGImageCreateWithMask(image.CGImage, mask)
        
        return UIImage(CGImage: masked!)
    }
}

extension DownloadableMaskedImageView : DownloadableImageViewDelegate
{
    func imageLoaded(imageView: DownloadableImageView) {
        if imageView == colorImageView
        {
            self.colorImageLoaded = true
        }
        else if imageView == maskImageView
        {
            self.maskImageLoaded = true
        }
        
        if self.colorImageLoaded && self.maskImageLoaded
        {
            self.setupLayers()
        }
    }
}