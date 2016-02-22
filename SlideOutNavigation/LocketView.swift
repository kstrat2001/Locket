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
    
    private var userLocket : UserLocket?
    
    private var openLocketImageView : DownloadableImageView?
    private var closedLocketImageView : DownloadableImageView?
    private var locketChainImageView : DownloadableImageView?
    private var backgroundImageView : DownloadableImageView?
    
    override init( frame: CGRect )
    {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUserLocket(userLocket: UserLocket!)
    {
        self.userLocket = userLocket
        
        self.setLocket(self.userLocket?.locket)
    }
    
    private func setLocket(locket: Locket!)
    {
        if let chain = locketChainImageView as UIImageView?
        {
            chain.removeFromSuperview()
        }
        
        if let locket = closedLocketImageView as UIImageView?
        {
            locket.removeFromSuperview()
        }

        locketChainImageView = createChainImage(locket)
        closedLocketImageView = createClosedLocketImage(locket)
    }
    
    func createClosedLocketImage( locket: Locket ) -> DownloadableImageView
    {
        let imageView = DownloadableImageView()
        self.addSubview(imageView)
        
        self.addImageConstraints( imageView, size: locket.closedImage.getSize(), position: locket.getClosedLocketPosition() )
        
        imageView.loadImageFromUrl(locket.closedImage.getImageUrl())
        
        return imageView
    }
    
    func createChainImage( locket: Locket ) -> DownloadableImageView
    {
        let imageView = DownloadableImageView()
        self.addSubview(imageView)
        
        self.addImageConstraints( imageView, size: locket.chainImage.getSize(), position: locket.getChainPosition() )
        
        imageView.loadImageFromUrl(locket.chainImage.getImageUrl())
        
        return imageView
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