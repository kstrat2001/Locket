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
    fileprivate var userLocket : UserLocketEntity!
    
    fileprivate var contentView: UIView! = UIView(frame: UIScreen.main.bounds)
    fileprivate var openLocketImageView : DownloadableImageView?
    fileprivate var closedLocketImageView : DownloadableImageView?
    fileprivate var locketChainImageView : DownloadableImageView?
    fileprivate var photoImageView : LocketPhotoView?
    fileprivate var captionLabel : UILabel?
    
    fileprivate var bgEditView : EditColorView?
    fileprivate var editingBackground : Bool! = false
    
    fileprivate var captionEditTextView : EditTextView?
    fileprivate var editingCaption : Bool! = false
    
    fileprivate var isAnimating : Bool = false
    fileprivate (set) var isClosed : Bool = true
    
    var delegate : LocketViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(contentView)
        
        captionEditTextView = EditTextView.loadFromNibNamed("EditTextView") as? EditTextView
        captionEditTextView?.frame = self.frame
        captionEditTextView?.delegate = self
        captionEditTextView?.initEvents()
        captionEditTextView?.isHidden = true
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
    
    func setUserLocket(_ userLocket: UserLocketEntity!)
    {
        self.userLocket = userLocket
        let skin = self.userLocket.locket_skin
        
        self.loadLocketSkin(skin!)
        
        if photoImageView == nil {
            photoImageView = LocketPhotoView(frame: self.frame,
                colorFrame: self.userLocket.getImageFrame(),
                maskFrame: (skin?.getMaskFrame())!,
                colorUrl: self.userLocket.image.imageURL,
                colorOrientation: UIImageOrientation(rawValue: Int(self.userLocket.image.orientation.int32Value))!,
                maskUrl: (skin?.mask_image.imageURL)!)
            photoImageView?.delegate = self
            
        } else {
            photoImageView?.loadAssets(
                self.userLocket.getImageFrame(),
                maskFrame: (skin?.getMaskFrame())!,
                colorUrl: self.userLocket.image.imageURL,
                colorOrientation: UIImageOrientation(rawValue: Int(self.userLocket.image.orientation.int32Value))!,
                maskUrl: (skin?.mask_image.imageURL)!)
        }
        
        photoImageView?.removeFromSuperview()
        contentView.insertSubview(photoImageView!, aboveSubview: locketChainImageView!)
        
        self.loadCaption()
        self.loadBackgroundColor()
    }
    
    fileprivate func loadLocketSkin(_ skin: LocketSkinEntity)
    {
        locketChainImageView?.removeFromSuperview()
        closedLocketImageView?.removeFromSuperview()
        openLocketImageView?.removeFromSuperview()
        
        locketChainImageView = nil
        closedLocketImageView = nil
        openLocketImageView = nil
        
        locketChainImageView = loadImage(skin.chain_image.imageURL as URL, size: skin.chain_image.frame.size, position: skin.getChainPosition())
        locketChainImageView?.isUserInteractionEnabled = false
        openLocketImageView = loadImage(skin.open_image.imageURL as URL, size: skin.open_image.frame.size, position: skin.getOpenLocketPosition())
        closedLocketImageView = loadImage(skin.closed_image.imageURL as URL, size: skin.closed_image.frame.size, position: skin.getClosedLocketPosition())
        
        // Init open/closed state
        closedLocketImageView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action:#selector(LocketView.locketTapped(_:))))
        closedLocketImageView?.isUserInteractionEnabled = true
        
        openLocketImageView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action:#selector(LocketView.locketTapped(_:))))
        self.openLocketImageView?.alpha = 0.0
        
        self.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(LocketView.viewLongPress(_:))))
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LocketView.viewTapped(_:))))
    }
    
    func loadBackgroundColor()
    {
        contentView.backgroundColor = UIColor.clear
        self.backgroundColor = userLocket.background_color.uicolor
    }
    
    func setPhoto(_ image: UIImage)
    {
        AnalyticsManager.sharedManager.settingsEvent("Locket Photo Set")
        
        let url = URL(string:"http://" + gFileHost + "/" + image.getUniqueString() + ".png")!
        if !FileManager.sharedManager.fileIsCached(url) {
            assert(DataManager.sharedManager.cacheImage(url, image: image))
        }
        
        self.userLocket.image.orientation = image.imageOrientation.rawValue as NSNumber!
        self.userLocket.image.image_full = url.absoluteString
        self.userLocket.image.image_thumb = url.absoluteString
        DataManager.sharedManager.saveAllRecords()
        photoImageView?.setPhoto(image)
    }
    
    func viewTapped(_ press: UITapGestureRecognizer)
    {
        let location = press.location(in: self)
        let height = self.frame.height
        
        if location.y < (height * 0.33) {
            if self.photoImageView?.inEditMode == false &&
                self.editingBackground == false {
                editBackground()
            }
        } else if location.y > (height * 0.66) {
            if self.photoImageView?.inEditMode == false &&
                self.editingCaption == false {
                editCaption()
            }
        } else if location.y > (height * 0.33) {
            if editingBackground == true {
                DataManager.sharedManager.saveAllRecords()
                self.stopEditingBackground()
            }
        }
    }
    
    func viewLongPress(_ press: UILongPressGestureRecognizer)
    {
        if press.state != UIGestureRecognizerState.began {
            return
        }
        
        let location = press.location(in: self)
        let height = self.frame.height
        
        if isClosed == false && location.y >= height * 0.33 && location.y <= height * 0.66 {
            if self.photoImageView?.inEditMode == false &&
                self.editingBackground == false &&
                self.editingCaption == false {
                editPhoto()
            }
        }
    }
    
    fileprivate func cleanupEditMode()
    {
        if(self.photoImageView?.inEditMode == false &&
            self.editingBackground == false &&
            self.editingCaption == false) {
                self.contentView.isUserInteractionEnabled = true
                delegate?.locketViewDidFinishEditing()
        }
    }
    
    fileprivate func editPhoto()
    {
        AnalyticsManager.sharedManager.settingsEvent("Edit Photo")
        delegate?.locketViewDidStartEditing()
        
        self.photoImageView?.toggleEditMode()
        
        UIView.animate(withDuration: gEditAnimationDuration, delay: 0, usingSpringWithDamping: gEditAnimationDamping, initialSpringVelocity: 1, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.locketChainImageView?.alpha = 0.0
                self.openLocketImageView?.alpha = 0.0
                self.captionLabel?.alpha = 0.0
            },
            completion: { (value: Bool) in
        })

    }
    
    fileprivate func stopEditingPhoto()
    {
        self.photoImageView?.toggleEditMode()
        UIView.animate(withDuration: gEditAnimationDuration, delay: 0, usingSpringWithDamping: gEditAnimationDamping, initialSpringVelocity: 1, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.locketChainImageView?.alpha = 1.0
                self.openLocketImageView?.alpha = 1.0
                self.captionLabel?.alpha = 1.0
            },
            completion: { (value: Bool) in
        })
        
        self.cleanupEditMode()
    }
    
    fileprivate func editBackground()
    {
        AnalyticsManager.sharedManager.settingsEvent("Edit Background")
        
        self.contentView.isUserInteractionEnabled = false
        editingBackground = true
        delegate?.locketViewDidStartEditing()
        bgEditView?.setColor(self.backgroundColor!)
        
        UIView.animate(withDuration: gEditAnimationDuration, delay: 0, usingSpringWithDamping: gEditAnimationDamping, initialSpringVelocity: 1, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.bgEditView?.transform = CGAffineTransform(translationX: 0, y: gBGEditViewHeight)
            },
            completion: { (value: Bool) in
        })
    }
    
    fileprivate func stopEditingBackground()
    {
        UIView.animate(withDuration: gEditAnimationDuration, delay: 0, usingSpringWithDamping: gEditAnimationDamping, initialSpringVelocity: 1, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.bgEditView?.transform = CGAffineTransform(translationX: 0, y: 0)
            },
            completion: { (value: Bool) in
                self.editingBackground = false
                self.cleanupEditMode()
        })
    }
    
    fileprivate func editCaption()
    {
        AnalyticsManager.sharedManager.settingsEvent("Edit Caption")
        
        contentView.isUserInteractionEnabled = false
        delegate?.locketViewDidStartEditing()
        captionEditTextView?.setTextFieldText(self.captionLabel!.text!)
        captionEditTextView?.isHidden = false
        
        UIView.animate(withDuration: gEditAnimationDuration, delay: 0, usingSpringWithDamping: gEditAnimationDamping, initialSpringVelocity: 1, options: UIViewAnimationOptions.curveEaseOut, animations: {
                let offset = UIScreen.main.bounds.height * (0.5 - (1.0 - gCaptionCenterYMultiplier))
                self.contentView.transform = CGAffineTransform(translationX: 0, y: -offset)
            },
            completion: { (value: Bool) in
        })
        
        self.captionEditTextView?.showKeyboard()
        editingCaption = true
    }
    
    fileprivate func stopEditingCaption()
    {
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.contentView.transform = CGAffineTransform(translationX: 0, y: 0)
            },
            completion: { (value: Bool ) in
                self.captionEditTextView?.isHidden = true
                self.editingCaption = false
                self.cleanupEditMode()
        })
    }
    
    func locketTapped(_ sender: UITapGestureRecognizer)
    {
        if isAnimating == true {
            return
        }
        
        // set up views to manipulate
        let fadingView = isClosed ? closedLocketImageView! : openLocketImageView!
        let incomingView = isClosed ? openLocketImageView! : closedLocketImageView!
        
        isClosed = !isClosed
        fadingView.isUserInteractionEnabled = false
        isAnimating = true
        
        UIView.animate(withDuration: 0.5, animations: {
            fadingView.alpha = 0.0
            incomingView.alpha = 1.0
            },
            completion: { (value: Bool) in
                self.isAnimating = false
                incomingView.isUserInteractionEnabled = true
            })
    }
    
    fileprivate func loadImage(_ url: URL, size: CGSize, position: CGPoint) -> DownloadableImageView
    {
        let imageView = DownloadableImageView()
        contentView.addSubview(imageView)
        
        self.addImageConstraints( imageView, size: size, position: position )
        
        imageView.loadImageFromUrl(url)
        
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOffset = CGSize(width: 4, height: 4)
        imageView.layer.shadowRadius = 7
        imageView.layer.shadowOpacity = 1.0
        
        return imageView
    }
    
    fileprivate func loadCaption()
    {
        if let label = self.captionLabel as UILabel?
        {
            label.removeFromSuperview()
        }
        
        let label = UILabel()
        
        contentView.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        self.addConstraint(NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.width, multiplier: 0.85, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 100))
        self.addConstraint(NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: gCaptionCenterYMultiplier, constant: 0))
        
        label.font = UIFont(name: self.userLocket.caption_font, size: gCaptionFontSize)
        label.text = self.userLocket.caption_text
        label.textColor = self.userLocket.caption_color.uicolor
        label.textAlignment = NSTextAlignment.center
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        
        captionLabel = label
    }
    
    fileprivate func addImageConstraints( _ imageView: UIImageView, size: CGSize, position: CGPoint )
    {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: size.width))
        self.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: size.height))
        self.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.left, multiplier: 1, constant: position.x))
        self.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.top, multiplier: 1, constant: position.y))
    }
}

extension LocketView : EditTextViewDelegate
{
    func editTextViewFinishedEditing() {
        DataManager.sharedManager.saveAllRecords()
        self.stopEditingCaption()
    }
    
    func editTextViewTextChanged(_ text: String) {
        self.captionLabel?.text = text
        self.userLocket.caption_text = text
    }
    
    func editTextViewFontChanged(_ font: String)
    {
        self.captionLabel?.font = UIFont(name: font, size: gCaptionFontSize)
        self.userLocket.caption_font = font
    }
    
    func editTextViewColorChanged(_ color: UIColor)
    {
        self.captionLabel?.textColor = color
        self.userLocket.caption_color.red = color.coreImageColor?.red as NSNumber!
        self.userLocket.caption_color.green = color.coreImageColor?.green as NSNumber!
        self.userLocket.caption_color.blue = color.coreImageColor?.blue as NSNumber!
    }
}

extension LocketView : LocketPhotoViewDelegate
{
    func didFinishEditing() {
        let anchorX = (self.closedLocketImageView?.frame.origin.x)! + CGFloat(self.userLocket.locket_skin.closed_image.anchor_x) - (self.photoImageView?.colorImageFrame.origin.x)!
        let anchorY = (self.closedLocketImageView?.frame.origin.y)! + CGFloat(self.userLocket.locket_skin.closed_image.anchor_y) - (self.photoImageView?.colorImageFrame.origin.y)!
        self.userLocket.image.anchor_x = NSNumber(value: Float(anchorX) as Float)
        self.userLocket.image.anchor_y = NSNumber(value: Float(anchorY) as Float)
        self.userLocket.image.width = self.photoImageView?.colorImageFrame.width as NSNumber!
        self.userLocket.image.height = self.photoImageView?.colorImageFrame.height as NSNumber!
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
    func EditColorViewColorChanged(_ color: UIColor) {
        self.backgroundColor = color
        self.userLocket.background_color.red = color.coreImageColor?.red as NSNumber!
        self.userLocket.background_color.green = color.coreImageColor?.green as NSNumber!
        self.userLocket.background_color.blue = color.coreImageColor?.blue as NSNumber!
    }
}
