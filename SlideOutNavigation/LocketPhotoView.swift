//
//  DownloadableMaskedImageView.swift
//  Locket
//
//  Created by Kain Osterholt on 2/22/16.
//  Copyright © 2016 James Frost. All rights reserved.
//

import Foundation
import UIKit

protocol LocketPhotoViewDelegate
{
    func didFinishEditing()
    
    func selectPhoto()
    func takePhoto()
}

class LocketPhotoView : UIView
{
    private (set) var colorDownload : DownloadableImageView?
    private (set) var fullScreencolorDownload: UIView?

    private (set) var maskDownload : DownloadableImageView?
    private (set) var maskImageView : MaskView?
    
    private (set) var finalImageView : UIImageView?
    
    private (set) var colorImageLoaded : Bool = false
    private (set) var maskImageLoaded : Bool = false
    
    private (set) var editButton : UIButton?
    private (set) var selectPhotoButton : UIButton?
    private (set) var takePhotoButton : UIButton?
    private (set) var inEditMode : Bool = false
    
    private (set) var colorImageFrame : CGRect = CGRect()
    private (set) var maskImageFrame : CGRect = CGRect()
    
    var delegate : LocketPhotoViewDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect, colorFrame: CGRect, maskFrame: CGRect, colorUrl: NSURL, maskUrl: NSURL)
    {
        super.init(frame: frame)
        
        fullScreencolorDownload = UIView(frame: frame)
        
        finalImageView = UIImageView(frame: frame)
        
        loadEditButton()
        loadSelectPhotoButton()
        loadTakePhotoButton()
        
        colorDownload = DownloadableImageView(frame: colorImageFrame)
        colorDownload?.delegate = self
        
        fullScreencolorDownload?.addSubview(colorDownload!)
        fullScreencolorDownload?.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "panHandler:"))
        fullScreencolorDownload?.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: "pinchHandler:"))
        
        maskDownload = DownloadableImageView(frame: maskFrame)
        maskDownload?.delegate = self

        maskImageView = MaskView(frame: frame)
        maskImageView?.addSubview(maskDownload!)
        
        self.addSubview(fullScreencolorDownload!)
        self.addSubview(finalImageView!)
        
        self.takePhotoButton?.hidden = true
        self.selectPhotoButton?.hidden = true
        self.editButton?.hidden = true
        self.bringSubviewToFront(self.editButton!)
        self.bringSubviewToFront(self.selectPhotoButton!)
        self.bringSubviewToFront(self.takePhotoButton!)
        
        loadAssets(colorFrame, maskFrame: maskFrame, colorUrl: colorUrl, maskUrl: maskUrl)
    }
    
    func loadAssets(colorFrame: CGRect, maskFrame: CGRect, colorUrl: NSURL, maskUrl: NSURL)
    {
        colorImageLoaded = false
        maskImageLoaded = false
        
        self.maskImageFrame = maskFrame
        calculateColorImageFrame(colorFrame, maskFrame: maskFrame)
        
        colorDownload?.frame = colorImageFrame
        maskDownload?.frame = maskFrame
        colorDownload?.loadImageFromUrl(colorUrl)
        maskDownload?.loadImageFromUrl(maskUrl)
    }
    
    func setPhoto(image: UIImage)
    {
        let scale = self.frame.width / image.size.width
        let width = image.size.width * scale
        let height = image.size.height * scale
        let desiredFrame = CGRect( x: 0.5 * (self.frame.width - width), y: 0.5 * (self.frame.height - height), width: width, height: height)
        
        calculateColorImageFrame(desiredFrame, maskFrame: self.maskImageFrame)
        
        colorDownload?.image = image
        colorDownload?.frame = colorImageFrame
    }
    
    private func calculateColorImageFrame(photoFrame: CGRect, maskFrame: CGRect)
    {
        if photoFrame.contains(maskFrame){
            colorImageFrame = photoFrame
        }
        else {
            let colorAspect = photoFrame.width / photoFrame.height
            let maskAspect = maskFrame.width / maskFrame.height
            if colorAspect > maskAspect {
                let newWidth = maskFrame.width * (colorAspect / maskAspect)
                let newX = maskFrame.origin.x - ((newWidth - maskFrame.width) * 0.5)
                colorImageFrame = CGRectMake(newX, maskFrame.origin.y, newWidth, maskFrame.height)
            }
            else {
                let newHeight = maskFrame.height * (maskAspect / colorAspect)
                let newY = maskFrame.origin.y - ((newHeight - maskFrame.height) * 0.5)
                colorImageFrame = CGRectMake(maskFrame.origin.x, newY, maskFrame.width, newHeight)
            }
        }
    }
    
    private func setupLayers()
    {
        maskImageView?.inverseMaskView?.removeFromSuperview()
        maskImageView?.updateMask()
        self.insertSubview((maskImageView?.inverseMaskView)!, aboveSubview: fullScreencolorDownload!)
        
        // Update the final image with the mask image
        self.updateFinalImage()
        
        (maskImageView?.inverseMaskView)!.alpha = 0.0
        fullScreencolorDownload!.alpha = 0.0
    }
    
    private func updateFinalImage()
    {
        fullScreencolorDownload!.alpha = 1.0
        let fullScreenColor = fullScreencolorDownload?.captureImage()
        
        finalImageView?.image = maskImageView?.applyMaskToImage(fullScreenColor!)
        self.bringSubviewToFront(finalImageView!)
    }
    
    func toggleEditMode()
    {
        inEditMode = !inEditMode
        
        if inEditMode == true
        {
            self.takePhotoButton?.hidden = false
            self.selectPhotoButton?.hidden = false
            self.editButton?.hidden = false
            
            UIView.animateWithDuration(gEditAnimationDuration, delay: 0, usingSpringWithDamping: gEditAnimationDamping, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    self.fullScreencolorDownload?.alpha = 1.0
                    (self.maskImageView?.inverseMaskView)!.alpha = 1.0
                    let transform = CGAffineTransformMakeTranslation(0, 0)
                    self.takePhotoButton?.transform = transform
                    self.selectPhotoButton?.transform = transform
                    self.editButton?.transform = transform
                },
                completion: { (value: Bool) in
                    self.finalImageView?.hidden = true

            })
        }
        else
        {
            self.updateFinalImage()
            finalImageView!.hidden = false
            
            UIView.animateWithDuration(gEditAnimationDuration, delay: 0, usingSpringWithDamping: gEditAnimationDamping, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    self.fullScreencolorDownload?.alpha = 0.0
                    (self.maskImageView?.inverseMaskView)!.alpha = 0.0
                    self.takePhotoButton?.transform = CGAffineTransformMakeTranslation(0, -100)
                    self.selectPhotoButton?.transform = CGAffineTransformMakeTranslation(0, -100)
                    self.editButton?.transform = CGAffineTransformMakeTranslation(0, 100)
                },
                completion: { (value: Bool) in
                    self.takePhotoButton?.hidden = true
                    self.selectPhotoButton?.hidden = true
                    self.editButton?.hidden = true
            })
        }
    }
    
    func panHandler(sender: UIPanGestureRecognizer)
    {
        let translation = sender.translationInView(fullScreencolorDownload!)
        let location = CGPoint(x: translation.x + colorImageFrame.origin.x, y: translation.y + colorImageFrame.origin.y)
        
        var newFrame = CGRect(origin: location, size: colorImageFrame.size)
        
        // clamp the new frame
        if newFrame.origin.x >= (maskDownload?.frame.origin.x)! - 1 {
            newFrame.origin.x = (maskDownload?.frame.origin.x)! - 1
        }
        
        if (newFrame.origin.x + colorImageFrame.width) <= ((maskDownload?.frame.width)! + (maskDownload?.frame.origin.x)! + 1) {
            newFrame.origin.x = (maskDownload?.frame.origin.x)! + (maskDownload?.frame.width)! - colorImageFrame.width + 1
        }
        
        if newFrame.origin.y >= (maskDownload?.frame.origin.y)! - 1 {
            newFrame.origin.y = (maskDownload?.frame.origin.y)! - 1
        }
        
        if (newFrame.origin.y + colorImageFrame.height) <= ((maskDownload?.frame.height)! + (maskDownload?.frame.origin.y)! + 1) {
            newFrame.origin.y = (maskDownload?.frame.origin.y)! + (maskDownload?.frame.height)! - colorImageFrame.height + 1
        }
        
        colorDownload?.frame = newFrame
        
        if sender.state == UIGestureRecognizerState.Ended {
            colorImageFrame = newFrame
        }
    }
    
    func pinchHandler(sender: UIPinchGestureRecognizer)
    {
        let xOffset = -(colorImageFrame.size.width * (sender.scale - 1.0)) * 0.5
        let yOffset = -(colorImageFrame.size.height * (sender.scale - 1.0)) * 0.5
        
        let newWidth = colorImageFrame.size.width * sender.scale
        let newHeight = colorImageFrame.size.height * sender.scale
        let newX = colorImageFrame.origin.x + xOffset
        let newY = colorImageFrame.origin.y + yOffset
        
        let newFrame = CGRectMake(newX, newY, newWidth, newHeight)
        
        if newFrame.contains((maskDownload?.frame)!){
            colorDownload?.frame = newFrame
        }
        
        if sender.state == UIGestureRecognizerState.Ended {
            colorImageFrame = (colorDownload?.frame)!
        }
    }
    
    private func loadEditButton()
    {
        let btnWidth : CGFloat = self.frame.width * 0.6
        let btnHeight : CGFloat = 50.0
        let btnFrame = CGRectMake( 0.5 * (self.frame.width - btnWidth), self.frame.height - btnHeight - 30.0, btnWidth, btnHeight)
        
        editButton = self.loadButton("done", frame: btnFrame)
        editButton?.transform = CGAffineTransformMakeTranslation(0, 100)
        addSubview(editButton!)
    }
    
    private func loadSelectPhotoButton()
    {
        let btnWidth : CGFloat = self.frame.width * 0.3
        let btnHeight : CGFloat = 50.0
        let btnFrame = CGRectMake( (0.25 * self.frame.width - 0.5 * btnWidth), 20, btnWidth, btnHeight)
        
        selectPhotoButton = self.loadButton("select", frame: btnFrame)
        selectPhotoButton?.transform = CGAffineTransformMakeTranslation(0, -100)
        addSubview(selectPhotoButton!)
    }
    
    private func loadTakePhotoButton()
    {
        let btnWidth : CGFloat = self.frame.width * 0.3
        let btnHeight : CGFloat = 50.0
        let btnFrame = CGRectMake( (0.75 * self.frame.width - 0.5 * btnWidth), 20, btnWidth, btnHeight)
        
        takePhotoButton = self.loadButton("take", frame: btnFrame)
        takePhotoButton?.transform = CGAffineTransformMakeTranslation(0, -100)
        addSubview(takePhotoButton!)
    }
    
    private func loadButton(title: String, frame: CGRect) -> UIButton
    {
        let button = UIButton(type: UIButtonType.RoundedRect)
        button.frame = frame
        button.layer.cornerRadius = 10
        button.backgroundColor = UIColor.whiteColor()
        button.titleLabel?.font = UIFont(name: "Helvetica", size: 20)
        button.setTitle(title, forState: UIControlState.Normal)
        button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        
        button.addTarget(self, action: "buttonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        
        return button
    }
    
    func buttonPressed(button: UIButton)
    {
        if button == editButton {
            delegate?.didFinishEditing()
        }
        else if button == selectPhotoButton {
            delegate?.selectPhoto()
        }
        else if button == takePhotoButton {
            delegate?.takePhoto()
        }
    }
}

extension LocketPhotoView : DownloadableImageViewDelegate
{
    func imageLoaded(imageView: DownloadableImageView) {
        if imageView == colorDownload
        {
            self.colorImageLoaded = true
            print("color image loaded")
        }
        else if imageView == maskDownload
        {
            self.maskImageLoaded = true
            print("mask image loaded")
        }
        
        if self.colorImageLoaded && self.maskImageLoaded
        {
            print("setting up layers")
            self.setupLayers()
        }
    }
}