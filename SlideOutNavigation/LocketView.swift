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

class LocketView : UIView
{
    
    private var userLocket : UserLocket = UserLocket.createDefaultUserLocket()
    
    private var openLocketImageView : DownloadableImageView?
    private var closedLocketImageView : DownloadableImageView?
    private var locketChainImageView : DownloadableImageView?
    private var photoImageView : DownloadableMaskedImageView?
    
    private var isAnimating : Bool = false
    
    @IBOutlet weak var captionLabel : UILabel?
    
    func setUserLocket(userLocket: UserLocket!)
    {
        self.userLocket = userLocket
        
        self.loadLocket()
        self.loadCaption()
    }
    
    private func loadLocket()
    {
        locketChainImageView?.removeFromSuperview()
        closedLocketImageView?.removeFromSuperview()
        openLocketImageView?.removeFromSuperview()
        photoImageView?.removeFromSuperview()
        
        let locket = self.userLocket.locket

        locketChainImageView = loadImage(locket.chainImage.getImageUrl(), size: locket.chainImage.getSize(), position: locket.getChainPosition())
        
        photoImageView = DownloadableMaskedImageView(frame: self.frame, maskFrame: locket.getMaskFrame(), colorUrl: self.userLocket.image.getImageUrl(), maskUrl: locket.maskImage.getImageUrl())
        self.addSubview(photoImageView!)
        
        openLocketImageView = loadImage(locket.openImage.getImageUrl(), size: locket.openImage.getSize(), position: locket.getOpenLocketPosition())
        closedLocketImageView = loadImage(locket.closedImage.getImageUrl(), size: locket.closedImage.getSize(), position: locket.getClosedLocketPosition())
        
        // Init open/closed state
        self.closedLocketImageView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action:Selector("locketPressed:")))
        self.closedLocketImageView?.userInteractionEnabled = true
        
        self.openLocketImageView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action:"locketPressed:"))
        self.openLocketImageView?.alpha = 0.0
    }
    
    func locketPressed(sender: UITapGestureRecognizer)
    {
        if closedLocketImageView?.userInteractionEnabled == true && !isAnimating
        {
            closedLocketImageView?.userInteractionEnabled = false
            isAnimating = true
            UIView.animateWithDuration(0.5, animations: {
                self.closedLocketImageView?.alpha = 0.0
                self.openLocketImageView?.alpha = 1.0
                },
                completion: { (value: Bool) in
                    self.isAnimating = false
                    self.openLocketImageView?.userInteractionEnabled = true
                })
        }
        else if openLocketImageView?.userInteractionEnabled == true && !isAnimating
        {
            openLocketImageView?.userInteractionEnabled = false
            isAnimating = true
            UIView.animateWithDuration(0.5, animations: {
                self.closedLocketImageView?.alpha = 1.0
                self.openLocketImageView?.alpha = 0.0
                },
                completion: { (value: Bool) in
                    self.isAnimating = false
                    self.closedLocketImageView?.userInteractionEnabled = true
                })
        }
    }
    
    private func loadImage(url: NSURL, size: CGSize, position: CGPoint) -> DownloadableImageView
    {
        let imageView = DownloadableImageView()
        self.addSubview(imageView)
        
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
        
        self.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        self.addConstraint(NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Width, multiplier: 0.9, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 40))
        self.addConstraint(NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 0.9, constant: 0))
        
        label.font = UIFont(name: self.userLocket.captionFont, size: 40)
        label.text = self.userLocket.captionText
        label.textAlignment = NSTextAlignment.Center
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
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