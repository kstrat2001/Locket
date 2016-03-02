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
    private (set) var colorImageView : DownloadableImageView?
    private (set) var fullScreenColorImageView: UIView?

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
    
    init(frame: CGRect, colorFrame: CGRect, maskFrame: CGRect, colorUrl: NSURL, maskUrl: NSURL)
    {
        super.init(frame: frame)
        
        fullScreenColorImageView = UIView(frame: frame)
        
        self.maskImageFrame = maskFrame
        calculateColorImageFrame(colorFrame, maskFrame: maskFrame)
        
        colorImageView = DownloadableImageView(frame: colorImageFrame)
        colorImageView?.delegate = self
        
        fullScreenColorImageView?.addSubview(colorImageView!)
        fullScreenColorImageView?.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "panHandler:"))
        fullScreenColorImageView?.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: "pinchHandler:"))
        
        maskImageView = MaskView(frame: frame)
        
        maskDownload = DownloadableImageView(frame: maskFrame)
        maskDownload?.delegate = self
        
        finalImageView = UIImageView(frame: frame)
        
        loadEditButton()
        loadSelectPhotoButton()
        loadTakePhotoButton()
        
        colorImageView?.loadImageFromUrl(colorUrl)
        maskDownload?.loadImageFromUrl(maskUrl)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setPhoto(image: UIImage)
    {
        let scale = self.frame.width / image.size.width
        let width = image.size.width * scale
        let height = image.size.height * scale
        let desiredFrame = CGRect( x: 0.5 * (self.frame.width - width), y: 0.5 * (self.frame.height - height), width: width, height: height)
        
        calculateColorImageFrame(desiredFrame, maskFrame: self.maskImageFrame)
        
        colorImageView?.image = image
        colorImageView?.frame = colorImageFrame
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
        let btnWidth : CGFloat = self.frame.width * 0.6
        let btnHeight : CGFloat = 50.0
        let btnFrame = CGRectMake( 0.5 * (self.frame.width - btnWidth), self.frame.height - btnHeight - 30.0, btnWidth, btnHeight)
        
        editButton = self.loadButton("done", frame: btnFrame)
        editButton?.hidden = !inEditMode
        addSubview(editButton!)
    }
    
    private func loadSelectPhotoButton()
    {
        let btnWidth : CGFloat = self.frame.width * 0.3
        let btnHeight : CGFloat = 50.0
        let btnFrame = CGRectMake( (0.25 * self.frame.width - 0.5 * btnWidth), 20, btnWidth, btnHeight)
        
        selectPhotoButton = self.loadButton("select", frame: btnFrame)
        selectPhotoButton?.hidden = !inEditMode
        addSubview(selectPhotoButton!)
    }
    
    private func loadTakePhotoButton()
    {
        let btnWidth : CGFloat = self.frame.width * 0.3
        let btnHeight : CGFloat = 50.0
        let btnFrame = CGRectMake( (0.75 * self.frame.width - 0.5 * btnWidth), 20, btnWidth, btnHeight)
        
        takePhotoButton = self.loadButton("take", frame: btnFrame)
        takePhotoButton?.hidden = !inEditMode
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
            selectPhotoButton?.hidden = false
            takePhotoButton?.hidden = false
            self.bringSubviewToFront(editButton!)
            self.bringSubviewToFront(selectPhotoButton!)
            self.bringSubviewToFront(takePhotoButton!)
        }
        else
        {
            fullScreenColorImageView?.removeFromSuperview()
            self.updateFinalImage()
            maskImageView?.inverseMaskView?.removeFromSuperview()
            self.addSubview(finalImageView!)
            self.backgroundColor = UIColor.clearColor()
            
            selectPhotoButton?.hidden = true
            takePhotoButton?.hidden = true
            editButton?.hidden = true
        }
    }
    
    func panHandler(sender: UIPanGestureRecognizer)
    {
        let translation = sender.translationInView(fullScreenColorImageView!)
        let location = CGPoint(x: translation.x + colorImageFrame.origin.x, y: translation.y + colorImageFrame.origin.y)
        
        var newFrame = CGRect(origin: location, size: colorImageFrame.size)
        
        // clamp the new frame
        if newFrame.origin.x > maskDownload?.frame.origin.x {
            newFrame.origin.x = (maskDownload?.frame.origin.x)!
        }
        
        if (newFrame.origin.x + colorImageFrame.width) < ((maskDownload?.frame.width)! + (maskDownload?.frame.origin.x)!) {
            newFrame.origin.x = (maskDownload?.frame.origin.x)! + (maskDownload?.frame.width)! - colorImageFrame.width
        }
        
        if newFrame.origin.y > maskDownload?.frame.origin.y {
            newFrame.origin.y = (maskDownload?.frame.origin.y)!
        }
        
        if (newFrame.origin.y + colorImageFrame.height) < ((maskDownload?.frame.height)! + (maskDownload?.frame.origin.y)!) {
            newFrame.origin.y = (maskDownload?.frame.origin.y)! + (maskDownload?.frame.height)! - colorImageFrame.height
        }
        
        colorImageView?.frame = newFrame
        
        if sender.state == UIGestureRecognizerState.Ended {
            colorImageFrame = (colorImageView?.frame)!
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
            colorImageView?.frame = newFrame
        }
        
        if sender.state == UIGestureRecognizerState.Ended {
            colorImageFrame = (colorImageView?.frame)!
        }
    }
}

extension LocketPhotoView : DownloadableImageViewDelegate
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