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
    fileprivate (set) var colorDownload : DownloadableImageView?
    fileprivate (set) var fullScreencolorDownload: UIView?

    fileprivate (set) var maskDownload : DownloadableImageView?
    fileprivate (set) var maskImageView : MaskView?
    
    fileprivate (set) var finalImageView : UIImageView?
    
    fileprivate (set) var colorImageLoaded : Bool = false
    fileprivate (set) var maskImageLoaded : Bool = false
    
    fileprivate (set) var doneButton : UIButton?
    fileprivate (set) var selectPhotoButton : UIButton?
    fileprivate (set) var takePhotoButton : UIButton?
    fileprivate (set) var inEditMode : Bool = false
    
    fileprivate (set) var colorImageFrame : CGRect = CGRect()
    fileprivate (set) var maskImageFrame : CGRect = CGRect()
    
    var delegate : LocketPhotoViewDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect, colorFrame: CGRect, maskFrame: CGRect, colorUrl: URL, colorOrientation: UIImageOrientation, maskUrl: URL)
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
        fullScreencolorDownload?.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(LocketPhotoView.panHandler(_:))))
        fullScreencolorDownload?.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(LocketPhotoView.pinchHandler(_:))))
        
        maskDownload = DownloadableImageView(frame: maskFrame)
        maskDownload?.delegate = self

        maskImageView = MaskView(frame: frame)
        maskImageView?.addSubview(maskDownload!)
        
        self.addSubview(fullScreencolorDownload!)
        self.addSubview(finalImageView!)
        
        self.takePhotoButton?.isHidden = true
        self.selectPhotoButton?.isHidden = true
        self.doneButton?.isHidden = true
        self.bringSubview(toFront: self.doneButton!)
        self.bringSubview(toFront: self.selectPhotoButton!)
        self.bringSubview(toFront: self.takePhotoButton!)
        
        loadAssets(colorFrame, maskFrame: maskFrame, colorUrl: colorUrl, colorOrientation: colorOrientation, maskUrl: maskUrl)
    }
    
    func loadAssets(_ colorFrame: CGRect, maskFrame: CGRect, colorUrl: URL, colorOrientation: UIImageOrientation, maskUrl: URL)
    {
        colorImageLoaded = false
        maskImageLoaded = false
        
        self.maskImageFrame = maskFrame
        calculateColorImageFrame(colorFrame, maskFrame: maskFrame)
        
        colorDownload?.frame = colorImageFrame
        maskDownload?.frame = maskFrame
        colorDownload?.loadImageFromUrl(colorUrl, orientation: colorOrientation)
        maskDownload?.loadImageFromUrl(maskUrl)
    }
    
    func setPhoto(_ image: UIImage)
    {
        let scale = self.frame.width / image.size.width
        let width = image.size.width * scale
        let height = image.size.height * scale
        let desiredFrame = CGRect( x: 0.5 * (self.frame.width - width), y: 0.5 * (self.frame.height - height), width: width, height: height)
        
        calculateColorImageFrame(desiredFrame, maskFrame: self.maskImageFrame)
        
        colorDownload?.image = image
        colorDownload?.frame = colorImageFrame
    }
    
    fileprivate func calculateColorImageFrame(_ photoFrame: CGRect, maskFrame: CGRect)
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
                colorImageFrame = CGRect(x: newX, y: maskFrame.origin.y, width: newWidth, height: maskFrame.height)
            }
            else {
                let newHeight = maskFrame.height * (maskAspect / colorAspect)
                let newY = maskFrame.origin.y - ((newHeight - maskFrame.height) * 0.5)
                colorImageFrame = CGRect(x: maskFrame.origin.x, y: newY, width: maskFrame.width, height: newHeight)
            }
        }
    }
    
    fileprivate func setupLayers()
    {
        maskImageView?.inverseMaskView?.removeFromSuperview()
        maskImageView?.updateMask()
        self.insertSubview((maskImageView?.inverseMaskView)!, aboveSubview: fullScreencolorDownload!)
        
        // Update the final image with the mask image
        self.updateFinalImage()
        
        (maskImageView?.inverseMaskView)!.alpha = 0.0
        fullScreencolorDownload!.alpha = 0.0
    }
    
    fileprivate func updateFinalImage()
    {
        fullScreencolorDownload!.alpha = 1.0
        let fullScreenColor = fullScreencolorDownload?.captureImage()
        
        finalImageView?.image = maskImageView?.applyMaskToImage(fullScreenColor!)
        self.bringSubview(toFront: finalImageView!)
    }
    
    func toggleEditMode()
    {
        inEditMode = !inEditMode
        
        if inEditMode == true
        {
            self.takePhotoButton?.isHidden = false
            self.selectPhotoButton?.isHidden = false
            self.doneButton?.isHidden = false
            
            UIView.animate(withDuration: gEditAnimationDuration, delay: 0, usingSpringWithDamping: gEditAnimationDamping, initialSpringVelocity: 1, options: UIViewAnimationOptions.curveEaseOut, animations: {
                    self.fullScreencolorDownload?.alpha = 1.0
                    (self.maskImageView?.inverseMaskView)!.alpha = 1.0
                    let transform = CGAffineTransform(translationX: 0, y: 0)
                    self.takePhotoButton?.transform = transform
                    self.selectPhotoButton?.transform = transform
                    self.doneButton?.transform = transform
                },
                completion: { (value: Bool) in
                    self.finalImageView?.isHidden = true

            })
        }
        else
        {
            self.updateFinalImage()
            finalImageView!.isHidden = false
            
            UIView.animate(withDuration: gEditAnimationDuration, delay: 0, usingSpringWithDamping: gEditAnimationDamping, initialSpringVelocity: 1, options: UIViewAnimationOptions.curveEaseOut, animations: {
                    self.fullScreencolorDownload?.alpha = 0.0
                    (self.maskImageView?.inverseMaskView)!.alpha = 0.0
                    self.takePhotoButton?.transform = CGAffineTransform(translationX: 0, y: -100)
                    self.selectPhotoButton?.transform = CGAffineTransform(translationX: 0, y: -100)
                    self.doneButton?.transform = CGAffineTransform(translationX: 0, y: 100)
                },
                completion: { (value: Bool) in
                    self.takePhotoButton?.isHidden = true
                    self.selectPhotoButton?.isHidden = true
                    self.doneButton?.isHidden = true
            })
        }
    }
    
    func panHandler(_ sender: UIPanGestureRecognizer)
    {
        let translation = sender.translation(in: fullScreencolorDownload!)
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
        
        if sender.state == UIGestureRecognizerState.ended {
            colorImageFrame = newFrame
        }
    }
    
    func pinchHandler(_ sender: UIPinchGestureRecognizer)
    {
        let xOffset = -(colorImageFrame.size.width * (sender.scale - 1.0)) * 0.5
        let yOffset = -(colorImageFrame.size.height * (sender.scale - 1.0)) * 0.5
        
        let newWidth = colorImageFrame.size.width * sender.scale
        let newHeight = colorImageFrame.size.height * sender.scale
        let newX = colorImageFrame.origin.x + xOffset
        let newY = colorImageFrame.origin.y + yOffset
        
        let newFrame = CGRect(x: newX, y: newY, width: newWidth, height: newHeight)
        
        if newFrame.contains((maskDownload?.frame)!){
            colorDownload?.frame = newFrame
        }
        
        if sender.state == UIGestureRecognizerState.ended {
            colorImageFrame = (colorDownload?.frame)!
        }
    }
    
    fileprivate func loadEditButton()
    {
        let btnWidth : CGFloat = self.frame.width * 0.6
        let btnHeight : CGFloat = 50.0
        let btnFrame = CGRect( x: 0.5 * (self.frame.width - btnWidth), y: self.frame.height - btnHeight - 30.0, width: btnWidth, height: btnHeight)
        
        doneButton = self.loadButton(btnFrame, title: "Done")
        doneButton?.transform = CGAffineTransform(translationX: 0, y: 100)
        addSubview(doneButton!)
    }
    
    fileprivate func loadSelectPhotoButton()
    {
        let btnWidth : CGFloat = self.frame.width * 0.3
        let btnHeight : CGFloat = 50.0
        let btnFrame = CGRect( x: (0.25 * self.frame.width - 0.5 * btnWidth), y: 20, width: btnWidth, height: btnHeight)
        
        selectPhotoButton = self.loadButton(btnFrame, imageName: "photo_lib_btn")
        selectPhotoButton?.transform = CGAffineTransform(translationX: 0, y: -100)
        addSubview(selectPhotoButton!)
    }
    
    fileprivate func loadTakePhotoButton()
    {
        let btnWidth : CGFloat = self.frame.width * 0.3
        let btnHeight : CGFloat = 50.0
        let btnFrame = CGRect( x: (0.75 * self.frame.width - 0.5 * btnWidth), y: 20, width: btnWidth, height: btnHeight)
        
        takePhotoButton = self.loadButton(btnFrame, imageName: "photo_btn")
        takePhotoButton?.transform = CGAffineTransform(translationX: 0, y: -100)

        addSubview(takePhotoButton!)

    }
    
    fileprivate func loadButton(_ frame: CGRect, imageName: String) -> UIButton
    {
        let button = UIButton(type: UIButtonType.roundedRect)
        button.frame = frame
        button.layer.cornerRadius = 10
        button.backgroundColor = UIColor.white
        
        let image = UIImage(named: imageName)?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        let aspect = image!.size.width / image!.size.height
        let iconHeight = frame.height * 0.75
        let iconWidth = iconHeight * aspect
        
        button.setImage(image, for: UIControlState())
        button.imageEdgeInsets = UIEdgeInsetsMake(0.5 * (frame.height - iconHeight), 0.5 * (frame.width - iconWidth), 0.5 * (frame.height - iconHeight), 0.5 * (frame.width - iconWidth))
        
        button.addTarget(self, action: #selector(LocketPhotoView.buttonPressed(_:)), for: UIControlEvents.touchUpInside)

        return button
    }
    
    fileprivate func loadButton(_ frame: CGRect, title: String) -> UIButton
    {
        let button = UIButton(type: UIButtonType.roundedRect)
        button.frame = frame
        button.layer.cornerRadius = 10
        button.backgroundColor = UIColor.white
        
        button.titleLabel?.font = UIFont(name: "Helvetica", size: 20)
        button.setTitle(title, for: UIControlState())
        button.setTitleColor(UIColor.black, for: UIControlState())
        
        button.addTarget(self, action: #selector(LocketPhotoView.buttonPressed(_:)), for: UIControlEvents.touchUpInside)
        
        return button
    }
    
    func buttonPressed(_ button: UIButton)
    {
        if button == doneButton {
            delegate?.didFinishEditing()
        }
        else if button == selectPhotoButton {
            AnalyticsManager.sharedManager.settingsEvent("Select Photo Button Pressed")
            delegate?.selectPhoto()
        }
        else if button == takePhotoButton {
            AnalyticsManager.sharedManager.settingsEvent("Take Photo Button Pressed")
            delegate?.takePhoto()
        }
    }
}

extension LocketPhotoView : DownloadableImageViewDelegate
{
    func imageLoaded(_ imageView: DownloadableImageView) {
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
