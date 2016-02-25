//
//  DownloadableMaskedImageView.swift
//  Locket
//
//  Created by Kain Osterholt on 2/22/16.
//  Copyright © 2016 James Frost. All rights reserved.
//

import Foundation
import UIKit

protocol DownloadableMaskedImageViewDelegate
{
    func didFinishEditing()
}

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
    
    private (set) var editButton : UIButton?
    private (set) var inEditMode : Bool = false
    
    var delegate : DownloadableMaskedImageViewDelegate?
    
    init(frame: CGRect, colorFrame: CGRect, maskFrame: CGRect, colorUrl: NSURL, maskUrl: NSURL)
    {
        super.init(frame: frame)
        
        fullScreenColorImageView = UIView(frame: frame)
        
        colorImageView = DownloadableImageView(frame: colorFrame)
        colorImageView?.delegate = self
        
        fullScreenColorImageView?.addSubview(colorImageView!)
        
        fullScreenMaskView = UIView(frame: frame)
        fullScreenMaskView?.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        
        maskImageView = DownloadableImageView(frame: maskFrame)
        maskImageView?.delegate = self
        
        fullScreenMaskView?.addSubview(maskImageView!)
        
        finalImageView = UIImageView(frame: frame)
        
        loadEditButton()
        
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
        
        // After securing the mask image we can set up the mask view for edit mode
        fullScreenMaskView?.backgroundColor = UIColor(white: 0.0, alpha: 0.1)
        
        // Update the final image with the mask image
        self.updateFinalImage()
        self.addSubview(finalImageView!)
    }
    
    func toggleEditMode()
    {
        inEditMode = !inEditMode
        
        if inEditMode == true
        {
            self.backgroundColor = UIColor.blackColor()
            self.insertSubview(fullScreenColorImageView!, belowSubview: finalImageView!)
            finalImageView?.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
            
            editButton?.hidden = false
            self.bringSubviewToFront(editButton!)
        }
        else
        {
            fullScreenColorImageView?.removeFromSuperview()
            self.backgroundColor = UIColor.clearColor()
            finalImageView?.backgroundColor = UIColor.clearColor()
            
            editButton?.hidden = true
        }
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
    
    private func loadEditButton()
    {
        let screenBounds = UIScreen.mainScreen().bounds
        let btnWidth : CGFloat = screenBounds.size.width * 0.6
        let btnHeight : CGFloat = 50.0
        let btnFrame = CGRectMake( 0.5 * (screenBounds.size.width - btnWidth), screenBounds.size.height - btnHeight - 30.0, btnWidth, btnHeight)
        
        editButton = UIButton(type: UIButtonType.RoundedRect)
        editButton?.frame = btnFrame
        editButton?.layer.cornerRadius = 10
        editButton?.backgroundColor = UIColor.whiteColor()
        editButton?.titleLabel?.font = UIFont(name: "Helvetica", size: 20)
        editButton?.setTitle("done", forState: UIControlState.Normal)
        editButton?.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        
        editButton?.addTarget(self, action: "editButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
        
        editButton?.hidden = !inEditMode
        addSubview(editButton!)
    }
    
    func editButtonPressed()
    {
        delegate?.didFinishEditing()
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