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

    private (set) var maskDownload : DownloadableImageView?
    private (set) var maskImageView : MaskView?
    
    private (set) var finalImageView : UIImageView?
    
    private (set) var colorImageLoaded : Bool = false
    private (set) var maskImageLoaded : Bool = false
    
    private (set) var editButton : UIButton?
    private (set) var inEditMode : Bool = false
    
    private (set) var colorImageFrame : CGRect = CGRect()
    
    var delegate : DownloadableMaskedImageViewDelegate?
    
    init(frame: CGRect, colorFrame: CGRect, maskFrame: CGRect, colorUrl: NSURL, maskUrl: NSURL)
    {
        super.init(frame: frame)
        
        fullScreenColorImageView = UIView(frame: frame)
        
        colorImageFrame = colorFrame
        colorImageView = DownloadableImageView(frame: colorFrame)
        colorImageView?.delegate = self
        
        fullScreenColorImageView?.addSubview(colorImageView!)
        fullScreenColorImageView?.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "panHandler:"))
        fullScreenColorImageView?.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: "pinchHandler:"))
        
        maskImageView = MaskView(frame: frame)
        
        maskDownload = DownloadableImageView(frame: maskFrame)
        maskDownload?.delegate = self
        
        finalImageView = UIImageView(frame: frame)
        
        loadEditButton()
        
        colorImageView?.loadImageFromUrl(colorUrl)
        maskDownload?.loadImageFromUrl(maskUrl)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupLayers()
    {
        maskImageView?.addSubview(maskDownload!)
        maskImageView?.backgroundColor = UIColor.whiteColor()
        maskImageView?.updateMask()
        
        // Update the final image with the mask image
        self.updateFinalImage()
        self.addSubview(finalImageView!)
    }
    
    private func updateFinalImage()
    {
        let fullScreenColor = fullScreenColorImageView?.captureImage()
        
        finalImageView?.image = maskImageView?.maskImage(fullScreenColor!)
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
    
    func toggleEditMode()
    {
        inEditMode = !inEditMode
        
        if inEditMode == true
        {
            self.backgroundColor = UIColor.blackColor()
            self.addSubview(fullScreenColorImageView!)
            finalImageView?.removeFromSuperview()
            self.addSubview((maskImageView?.inverseMaskView)!)
            
            editButton?.hidden = false
            self.bringSubviewToFront(editButton!)
        }
        else
        {
            fullScreenColorImageView?.removeFromSuperview()
            self.updateFinalImage()
            maskImageView?.inverseMaskView?.removeFromSuperview()
            self.addSubview(finalImageView!)
            self.backgroundColor = UIColor.clearColor()
            
            editButton?.hidden = true
        }
    }
    
    func editButtonPressed()
    {
        delegate?.didFinishEditing()
    }
    
    func panHandler(sender: UIPanGestureRecognizer)
    {
        let translation = sender.translationInView(fullScreenColorImageView!)
        let location = CGPoint(x: translation.x + colorImageFrame.origin.x, y: translation.y + colorImageFrame.origin.y)
        
        let newFrame = CGRect(origin: location, size: colorImageFrame.size)
        
        colorImageView?.frame = newFrame
        
        if sender.state == UIGestureRecognizerState.Ended {
            colorImageFrame = newFrame
        }
    }
    
    func pinchHandler(sender: UIPinchGestureRecognizer)
    {
        let xOffset = -(colorImageFrame.size.width * (sender.scale - 1.0)) * 0.5
        let yOffset = -(colorImageFrame.size.height * (sender.scale - 1.0)) * 0.5
        let translate = CGAffineTransformMakeTranslation(xOffset, yOffset)
        let scale = CGAffineTransformMakeScale(sender.scale, sender.scale)
        
        let finalTransform = CGAffineTransformConcat(scale, translate)

        let newFrame = CGRectApplyAffineTransform(colorImageFrame, finalTransform)
        
        colorImageView?.frame = newFrame
        
        if sender.state == UIGestureRecognizerState.Ended {
            colorImageFrame = newFrame
        }
    }
}

extension DownloadableMaskedImageView : DownloadableImageViewDelegate
{
    func imageLoaded(imageView: DownloadableImageView) {
        if imageView == colorImageView
        {
            self.colorImageLoaded = true
        }
        else if imageView == maskDownload
        {
            self.maskImageLoaded = true
        }
        
        if self.colorImageLoaded && self.maskImageLoaded
        {
            self.setupLayers()
        }
    }
}