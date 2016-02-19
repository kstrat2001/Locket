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
    
    private var _locket : Locket?
    
    private var openLocketImageView : UIImageView?
    private var closedLocketImageView : UIImageView?
    private var locketChainImageView : UIImageView?
    private var backgroundImageView : UIImageView?
    
    override init( frame: CGRect )
    {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setLocket(locket: Locket!)
    {
        _locket = locket
        
        if let chain = locketChainImageView as UIImageView?
        {
            chain.removeFromSuperview()
        }
        
        if let locket = closedLocketImageView as UIImageView?
        {
            locket.removeFromSuperview()
        }

        locketChainImageView = createChainImage(_locket!)
        closedLocketImageView = createClosedLocketImage(_locket!)
    }
    
    func createClosedLocketImage( locket: Locket ) -> UIImageView
    {
        let imageView = UIImageView()
        self.addSubview(imageView)
        
        self.addImageConstraints( imageView, size: locket.closedImage.getSize(), position: locket.getClosedLocketPosition() )
        
        imageView.af_setImageWithURL(locket.closedImage.getImageUrl())
        
        return imageView
    }
    
    func createChainImage( locket: Locket ) -> UIImageView
    {
        let imageView = UIImageView()
        self.addSubview(imageView)
        
        self.addImageConstraints( imageView, size: locket.chainImage.getSize(), position: locket.getChainPosition() )
        
        imageView.af_setImageWithURL(locket.chainImage.getImageUrl())
        
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