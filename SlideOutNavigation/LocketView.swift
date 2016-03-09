//
//  LocketView.swift
//  Locket
//
//  Created by Kain Osterholt on 12/30/15.
//  Copyright © 2015 Kain Osterholt. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

protocol LocketViewDelegate
{
    func locketViewDidStartEditing()
    func locketViewDidFinishEditing()
    func selectPhoto()
    func takePhoto()
}

class LocketView : UIView
{
    private var userLocket : UserLocket = UserLocket.createDefaultUserLocket()
    
    private var contentView: UIView! = UIView(frame: UIScreen.mainScreen().bounds)
    private var openLocketImageView : DownloadableImageView?
    private var closedLocketImageView : DownloadableImageView?
    private var locketChainImageView : DownloadableImageView?
    private var photoImageView : LocketPhotoView?
    private var captionLabel : UILabel?
    
    private var bgEditView : EditColorView?
    private var editingBackground : Bool! = false
    
    private var captionEditTextView : EditTextView?
    private var editingCaption : Bool! = false
    
    private var isAnimating : Bool = false
    private (set) var isClosed : Bool = true
    
    var delegate : LocketViewDelegate?
    
    func setUserLocket(userLocket: UserLocket!)
    {
        self.userLocket = userLocket
        
        self.loadLocket()
        self.loadCaption()
        self.loadBackgroundColor()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(contentView)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func loadLocket()
    {
        locketChainImageView?.removeFromSuperview()
        closedLocketImageView?.removeFromSuperview()
        openLocketImageView?.removeFromSuperview()
        photoImageView?.removeFromSuperview()
        
        let locket = self.userLocket.locket

        locketChainImageView = loadImage(locket.chainImage.getImageUrl(), size: locket.chainImage.frame.size, position: locket.getChainPosition())
        locketChainImageView?.userInteractionEnabled = false
        
        photoImageView = LocketPhotoView(frame: self.frame,
            colorFrame: self.userLocket.getImageFrame(),
            maskFrame: locket.getMaskFrame(),
            colorUrl: self.userLocket.image.getImageUrl(),
            maskUrl: locket.maskImage.getImageUrl())
        
        photoImageView?.delegate = self
        
        contentView.addSubview(photoImageView!)
        
        openLocketImageView = loadImage(locket.openImage.getImageUrl(), size: locket.openImage.frame.size, position: locket.getOpenLocketPosition())
        closedLocketImageView = loadImage(locket.closedImage.getImageUrl(), size: locket.closedImage.frame.size, position: locket.getClosedLocketPosition())
        
        // Init open/closed state
        self.closedLocketImageView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action:Selector("locketTapped:")))
        self.closedLocketImageView?.userInteractionEnabled = true
        
        self.openLocketImageView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action:"locketTapped:"))
        self.openLocketImageView?.alpha = 0.0
        
        self.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: "viewLongPress:"))
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "viewTapped:"))
    }
    
    func loadBackgroundColor()
    {
        contentView.backgroundColor = UIColor.clearColor()
        self.backgroundColor = userLocket.backgroundColor
    }
    
    func setPhoto(image: UIImage)
    {
        photoImageView?.setPhoto(image)
    }
    
    func viewTapped(tap: UITapGestureRecognizer)
    {
        if tap.locationInView(self).y > bgEditView?.frame.height {
            self.stopEditingBackground()
        }
        
    }
    
    func viewLongPress(press: UILongPressGestureRecognizer)
    {
        if press.state != UIGestureRecognizerState.Began {
            return
        }
        
        let location = press.locationInView(self)
        let height = self.frame.height
        
        if isClosed == false && location.y >= height * 0.33 && location.y <= height * 0.66 {
            editPhoto()
        }
        else if location.y < (height * 0.33) {
            editBackground()
        }
        else if location.y > (height * 0.66) {
            editCaption()
        }
    }
    
    func editPhoto()
    {
        if(self.photoImageView?.inEditMode == false)
        {
            delegate?.locketViewDidStartEditing()
            openLocketImageView?.hidden = true
            closedLocketImageView?.hidden = true
            locketChainImageView?.hidden = true
            captionLabel?.hidden = true
            self.photoImageView?.toggleEditMode()
        }
    }
    
    func stopEditingPhoto()
    {
        if self.photoImageView?.inEditMode == true {
            self.photoImageView?.toggleEditMode()
            openLocketImageView?.hidden = false
            closedLocketImageView?.hidden = false
            locketChainImageView?.hidden = false
            captionLabel?.hidden = false
            
            delegate?.locketViewDidFinishEditing()
        }
    }
    
    func editBackground()
    {
        if bgEditView == nil {
            bgEditView = EditColorView.loadFromNibNamed("EditColorView") as? EditColorView
            
            bgEditView?.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 155)
            bgEditView?.delegate = self
            bgEditView?.initEvents()
        }
        
        openLocketImageView?.userInteractionEnabled = false
        closedLocketImageView?.userInteractionEnabled = false
        captionLabel?.userInteractionEnabled = false
        delegate?.locketViewDidStartEditing()
        
        bgEditView?.setColor(self.backgroundColor!)
        self.addSubview(bgEditView!)
        
        editingBackground = true
    }
    
    func stopEditingBackground()
    {
        if editingBackground == true {
            bgEditView?.removeFromSuperview()
            openLocketImageView?.userInteractionEnabled = true
            closedLocketImageView?.userInteractionEnabled = true
            captionLabel?.userInteractionEnabled = true
            delegate?.locketViewDidFinishEditing()
            
            editingBackground = false
        }
    }
    
    func editCaption()
    {
        if captionEditTextView == nil {
            captionEditTextView = EditTextView.loadFromNibNamed("EditTextView") as? EditTextView
            captionEditTextView?.frame = self.frame
            captionEditTextView?.delegate = self
            captionEditTextView?.initEvents()
        }
        
        contentView.userInteractionEnabled = false
        delegate?.locketViewDidStartEditing()
        captionEditTextView?.setTextFieldText(self.captionLabel!.text!)
        captionEditTextView?.alpha = 0.0
        self.addSubview(self.captionEditTextView!)
        
        UIView.animateWithDuration(0.7, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                let offset = UIScreen.mainScreen().bounds.height * (0.5 - (1.0 - gCaptionCenterYMultiplier))
                self.contentView.transform = CGAffineTransformMakeTranslation(0, -offset)
                self.captionEditTextView?.alpha = 1.0
            },
            completion: { (value: Bool) in
                self.captionEditTextView?.showKeyboard()
        })

        editingCaption = true
    }
    
    func stopEditingCaption()
    {
        if editingCaption == true {
            
            UIView.animateWithDuration(0.7, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    self.contentView.transform = CGAffineTransformMakeTranslation(0, 0)
                    self.captionEditTextView?.alpha = 0.0
                },
                completion: { (value: Bool ) in
                    self.captionEditTextView?.removeFromSuperview()
                    self.contentView.userInteractionEnabled = true
                    self.delegate?.locketViewDidFinishEditing()
                    
                    self.contentView.transform = CGAffineTransformMakeTranslation(0, 0)
                    self.editingCaption = false
            })
        }
    }
    
    func locketTapped(sender: UITapGestureRecognizer)
    {
        if isAnimating == true {
            return
        }
        
        // set up views to manipulate
        let fadingView = isClosed ? closedLocketImageView! : openLocketImageView!
        let incomingView = isClosed ? openLocketImageView! : closedLocketImageView!
        
        isClosed = !isClosed
        fadingView.userInteractionEnabled = false
        isAnimating = true
        
        UIView.animateWithDuration(0.5, animations: {
            fadingView.alpha = 0.0
            incomingView.alpha = 1.0
            },
            completion: { (value: Bool) in
                self.isAnimating = false
                incomingView.userInteractionEnabled = true
            })
    }
    
    private func loadImage(url: NSURL, size: CGSize, position: CGPoint) -> DownloadableImageView
    {
        let imageView = DownloadableImageView()
        contentView.addSubview(imageView)
        
        self.addImageConstraints( imageView, size: size, position: position )
        
        imageView.loadImageFromUrl(url)
        
        return imageView
    }
    
    private func loadCaption()
    {
        if let label = self.captionLabel as UILabel?
        {
            label.removeFromSuperview()
        }
        
        let label = UILabel()
        
        contentView.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        self.addConstraint(NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Width, multiplier: 0.85, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 40))
        self.addConstraint(NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: gCaptionCenterYMultiplier, constant: 0))
        
        label.font = UIFont(name: self.userLocket.captionFont, size: gCaptionFontSize)
        label.text = self.userLocket.captionText
        label.textAlignment = NSTextAlignment.Center
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        
        captionLabel = label
    }
    
    private func addImageConstraints( imageView: UIImageView, size: CGSize, position: CGPoint )
    {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: size.width))
        self.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: size.height))
        self.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: position.x))
        self.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: position.y))
    }
}

extension LocketView : EditTextViewDelegate
{
    func editTextViewFinishedEditing() {
        self.stopEditingCaption()
    }
    
    func editTextViewTextChanged(text: String) {
        self.captionLabel?.text = text
    }
    
    func editTextViewFontChanged(font: String)
    {
        self.captionLabel?.font = UIFont(name: font, size: gCaptionFontSize)
    }
    
    func editTextViewColorChanged(color: UIColor)
    {
        self.captionLabel?.textColor = color
    }
}

extension LocketView : LocketPhotoViewDelegate
{
    func didFinishEditing() {
        self.stopEditingPhoto()
    }
    
    func selectPhoto() {
        delegate?.selectPhoto()
    }
    
    func takePhoto()
    {
        delegate?.takePhoto()
    }
}

extension LocketView : EditColorViewDelegate
{
    func EditColorViewColorChanged(color: UIColor) {
        self.backgroundColor = color
    }
}