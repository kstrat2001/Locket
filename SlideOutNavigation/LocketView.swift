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
import CryptoSwift

protocol LocketViewDelegate
{
    func locketViewDidStartEditing()
    func locketViewDidFinishEditing()
    func selectPhoto()
    func takePhoto()
}

class LocketView : UIView
{
    private var userLocket : UserLocketEntity!
    
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(contentView)
        
        captionEditTextView = EditTextView.loadFromNibNamed("EditTextView") as? EditTextView
        captionEditTextView?.frame = self.frame
        captionEditTextView?.delegate = self
        captionEditTextView?.initEvents()
        captionEditTextView?.hidden = true
        self.addSubview(self.captionEditTextView!)
        
        bgEditView = EditColorView.loadFromNibNamed("EditColorView") as? EditColorView
        
        bgEditView?.frame = CGRect(x: 0, y: -gBGEditViewHeight, width: self.frame.width, height: gBGEditViewHeight)
        bgEditView?.delegate = self
        bgEditView?.initEvents()
        self.addSubview(bgEditView!)
        
        self.userLocket = SettingsManager.sharedManager.selectedLocket
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setUserLocket(userLocket: UserLocketEntity!)
    {
        self.userLocket = userLocket
        let skin = self.userLocket.locket_skin
        
        self.loadLocketSkin(skin)
        
        if photoImageView == nil {
            photoImageView = LocketPhotoView(frame: self.frame,
                colorFrame: self.userLocket.getImageFrame(),
                maskFrame: skin.getMaskFrame(),
                colorUrl: self.userLocket.image.imageURL,
                maskUrl: skin.mask_image.imageURL)
            photoImageView?.delegate = self
            
        } else {
            photoImageView?.loadAssets(
                self.userLocket.getImageFrame(),
                maskFrame: skin.getMaskFrame(),
                colorUrl: self.userLocket.image.imageURL,
                maskUrl: skin.mask_image.imageURL)
        }
        
        photoImageView?.removeFromSuperview()
        contentView.insertSubview(photoImageView!, aboveSubview: locketChainImageView!)
        
        self.loadCaption()
        self.loadBackgroundColor()
    }
    
    private func loadLocketSkin(skin: LocketSkinEntity)
    {
        locketChainImageView?.removeFromSuperview()
        closedLocketImageView?.removeFromSuperview()
        openLocketImageView?.removeFromSuperview()
        
        locketChainImageView = nil
        closedLocketImageView = nil
        openLocketImageView = nil
        
        locketChainImageView = loadImage(skin.chain_image.imageURL, size: skin.chain_image.frame.size, position: skin.getChainPosition())
        locketChainImageView?.userInteractionEnabled = false
        openLocketImageView = loadImage(skin.open_image.imageURL, size: skin.open_image.frame.size, position: skin.getOpenLocketPosition())
        closedLocketImageView = loadImage(skin.closed_image.imageURL, size: skin.closed_image.frame.size, position: skin.getClosedLocketPosition())
        
        // Init open/closed state
        closedLocketImageView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action:#selector(LocketView.locketTapped(_:))))
        closedLocketImageView?.userInteractionEnabled = true
        
        openLocketImageView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action:#selector(LocketView.locketTapped(_:))))
        self.openLocketImageView?.alpha = 0.0
        
        self.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(LocketView.viewLongPress(_:))))
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LocketView.viewTapped(_:))))
    }
    
    func loadBackgroundColor()
    {
        contentView.backgroundColor = UIColor.clearColor()
        self.backgroundColor = userLocket.background_color.uicolor
    }
    
    func setPhoto(image: UIImage)
    {
        let url = NSURL(string:"http://" + gFileHost + "/" + image.getUniqueString() + ".png")!
        if !FileManager.sharedManager.fileIsCached(url) {
            DataManager.sharedManager.cacheImage(url, image: image)
        }

        self.userLocket.image.image_full = url.absoluteString
        self.userLocket.image.image_thumb = url.absoluteString
        DataManager.sharedManager.saveAllRecords()
        photoImageView?.setPhoto(image)
    }
    
    func viewTapped(tap: UITapGestureRecognizer)
    {
        if tap.locationInView(self).y > bgEditView?.frame.height {
            if editingBackground == true {
                DataManager.sharedManager.saveAllRecords()
                self.stopEditingBackground()
            }
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
            if self.photoImageView?.inEditMode == false &&
                self.editingBackground == false &&
                self.editingCaption == false {
                editPhoto()
            }
        }
        else if location.y < (height * 0.33) {
            if self.photoImageView?.inEditMode == false &&
                self.editingBackground == false {
                editBackground()
            }
        }
        else if location.y > (height * 0.66) {
            if self.photoImageView?.inEditMode == false &&
                self.editingCaption == false {
                editCaption()
            }
        }
    }
    
    private func cleanupEditMode()
    {
        if(self.photoImageView?.inEditMode == false &&
            self.editingBackground == false &&
            self.editingCaption == false) {
                self.contentView.userInteractionEnabled = true
                delegate?.locketViewDidFinishEditing()
        }
    }
    
    private func editPhoto()
    {
        delegate?.locketViewDidStartEditing()
        
        self.photoImageView?.toggleEditMode()
        
        UIView.animateWithDuration(gEditAnimationDuration, delay: 0, usingSpringWithDamping: gEditAnimationDamping, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.locketChainImageView?.alpha = 0.0
                self.openLocketImageView?.alpha = 0.0
                self.captionLabel?.alpha = 0.0
            },
            completion: { (value: Bool) in
        })

    }
    
    private func stopEditingPhoto()
    {
        self.photoImageView?.toggleEditMode()
        UIView.animateWithDuration(gEditAnimationDuration, delay: 0, usingSpringWithDamping: gEditAnimationDamping, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.locketChainImageView?.alpha = 1.0
                self.openLocketImageView?.alpha = 1.0
                self.captionLabel?.alpha = 1.0
            },
            completion: { (value: Bool) in
        })
        
        self.cleanupEditMode()
    }
    
    private func editBackground()
    {
        self.contentView.userInteractionEnabled = false
        editingBackground = true
        delegate?.locketViewDidStartEditing()
        bgEditView?.setColor(self.backgroundColor!)
        
        UIView.animateWithDuration(gEditAnimationDuration, delay: 0, usingSpringWithDamping: gEditAnimationDamping, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.bgEditView?.transform = CGAffineTransformMakeTranslation(0, gBGEditViewHeight)
            },
            completion: { (value: Bool) in
        })
    }
    
    private func stopEditingBackground()
    {
        UIView.animateWithDuration(gEditAnimationDuration, delay: 0, usingSpringWithDamping: gEditAnimationDamping, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.bgEditView?.transform = CGAffineTransformMakeTranslation(0, 0)
            },
            completion: { (value: Bool) in
                self.editingBackground = false
                self.cleanupEditMode()
        })
    }
    
    private func editCaption()
    {
        contentView.userInteractionEnabled = false
        delegate?.locketViewDidStartEditing()
        captionEditTextView?.setTextFieldText(self.captionLabel!.text!)
        captionEditTextView?.hidden = false
        
        UIView.animateWithDuration(gEditAnimationDuration, delay: 0, usingSpringWithDamping: gEditAnimationDamping, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                let offset = UIScreen.mainScreen().bounds.height * (0.5 - (1.0 - gCaptionCenterYMultiplier))
                self.contentView.transform = CGAffineTransformMakeTranslation(0, -offset)
            },
            completion: { (value: Bool) in
        })
        
        self.captionEditTextView?.showKeyboard()
        editingCaption = true
    }
    
    private func stopEditingCaption()
    {
        UIView.animateWithDuration(0.7, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.contentView.transform = CGAffineTransformMakeTranslation(0, 0)
            },
            completion: { (value: Bool ) in
                self.captionEditTextView?.hidden = true
                self.editingCaption = false
                self.cleanupEditMode()
        })
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
        self.addConstraint(NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 80))
        self.addConstraint(NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: gCaptionCenterYMultiplier, constant: 0))
        
        label.font = UIFont(name: self.userLocket.caption_font, size: gCaptionFontSize)
        label.text = self.userLocket.caption_text
        label.textColor = self.userLocket.caption_color.uicolor
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
        DataManager.sharedManager.saveAllRecords()
        self.stopEditingCaption()
    }
    
    func editTextViewTextChanged(text: String) {
        self.captionLabel?.text = text
        self.userLocket.caption_text = text
    }
    
    func editTextViewFontChanged(font: String)
    {
        self.captionLabel?.font = UIFont(name: font, size: gCaptionFontSize)
        self.userLocket.caption_font = font
    }
    
    func editTextViewColorChanged(color: UIColor)
    {
        self.captionLabel?.textColor = color
        self.userLocket.caption_color.red = color.coreImageColor?.red
        self.userLocket.caption_color.green = color.coreImageColor?.green
        self.userLocket.caption_color.blue = color.coreImageColor?.blue
    }
}

extension LocketView : LocketPhotoViewDelegate
{
    func didFinishEditing() {
        let anchorX = (self.closedLocketImageView?.frame.origin.x)! + CGFloat(self.userLocket.locket_skin.closed_image.anchor_x) - (self.photoImageView?.colorImageFrame.origin.x)!
        let anchorY = (self.closedLocketImageView?.frame.origin.y)! + CGFloat(self.userLocket.locket_skin.closed_image.anchor_y) - (self.photoImageView?.colorImageFrame.origin.y)!
        self.userLocket.image.anchor_x = NSNumber(float: Float(anchorX))
        self.userLocket.image.anchor_y = NSNumber(float: Float(anchorY))
        self.userLocket.image.width = self.photoImageView?.colorImageFrame.width
        self.userLocket.image.height = self.photoImageView?.colorImageFrame.height
        DataManager.sharedManager.saveAllRecords()
        
        self.stopEditingPhoto()
    }
    
    func selectPhoto() {
        delegate?.selectPhoto()
    }
    
    func takePhoto() {
        delegate?.takePhoto()
    }
}

extension LocketView : EditColorViewDelegate
{
    func EditColorViewColorChanged(color: UIColor) {
        self.backgroundColor = color
        self.userLocket.background_color.red = color.coreImageColor?.red
        self.userLocket.background_color.green = color.coreImageColor?.green
        self.userLocket.background_color.blue = color.coreImageColor?.blue
    }
}