//
//  Locket.swift
//  Locket app
//
//  Created by Kain Osterholt on 03/08/2014.
//  Copyright (c) 2016 Kain Osterholt. All rights reserved.
//

import UIKit

class ImageAsset
{
    let data: NSDictionary!
    let anchor: CGPoint!
    let size: CGSize!
    
    init(assetData: NSDictionary!)
    {
        data = assetData
        
        let scaleFactor : CGFloat = 1.0 / 3.0
        let width: CGFloat = scaleFactor * (data["width"] as! CGFloat)
        let height: CGFloat = scaleFactor * (data["height"] as! CGFloat)
        
        size = CGSize( width: width, height: height )
        
        let anchorX = scaleFactor * (data["anchor_x"] as! CGFloat)
        let anchorY = scaleFactor * (data["anchor_y"] as! CGFloat)
        
        anchor = CGPoint( x: anchorX, y: anchorY )
    }
    
    func getTitle() -> String
    {
        return data["title"] as! String
    }
    
    func getThumbUrl() -> NSURL
    {
        let thumbStr : String = data["image_thumb"] as! String
        return NSURL(string: thumbStr)!
    }
    
    func getImageUrl() -> NSURL
    {
        let imageStr = data["image_full"] as! String
        return NSURL(string: imageStr)!
    }
    
    func getAnchor() -> CGPoint
    {
        return anchor
    }
    
    func getSize() -> CGSize
    {
        return size
    }
    
    class func createDefaultImageAsset() -> ImageAsset
    {
        let data : NSDictionary = [
            "title" : "default",
            "anchor_x" : 678,
            "anchor_y" : 34,
            "width" : 1187,
            "height" : 994,
            "image_full" : "http://mainbundle.app/default_image.png",
            "image_thumb" : "http://mainbundle.app/default_image.png"
        ]
        
        return ImageAsset(assetData: data)
    }
}

class Locket
{
  
    let data: NSDictionary!
    let closedImage: ImageAsset!
    let openImage: ImageAsset!
    let chainImage: ImageAsset!
    let maskImage: ImageAsset!

    init(locketData: NSDictionary!)
    {
        self.data = locketData
        
        openImage = ImageAsset(assetData: self.data["open_image"] as! NSDictionary )
        closedImage = ImageAsset(assetData: self.data["closed_image"] as! NSDictionary )
        chainImage = ImageAsset(assetData: self.data["chain_image"] as! NSDictionary )
        maskImage = ImageAsset(assetData: self.data["mask_image"] as! NSDictionary )
    }
    
    class func loadLockets(data: NSDictionary!) -> Array<Locket>
    {
        let lockets = data["lockets"] as! Array<NSDictionary>
        
        var returnLockets = Array<Locket>()
        
        returnLockets.append(Locket.createDefaultLocket())
        
        for locket in lockets
        {
            returnLockets.append(Locket(locketData: locket))
        }
        
        return returnLockets
    }
    
    func getTitle() -> String
    {
        return self.data["title"] as! String
    }
    
    func getThumbUrl() -> NSURL
    {
        return closedImage.getThumbUrl()
    }
    
    func getClosedLocketPosition() -> CGPoint
    {
        let width = UIScreen.mainScreen().bounds.size.width
        let height = UIScreen.mainScreen().bounds.size.height
        
        let x = 0.5 * (width - closedImage.getSize().width)
        let y = 0.5 * (height - closedImage.getSize().height)
        
        return CGPoint( x: x, y: y )
    }
    
    func getChainPosition() -> CGPoint
    {
        return getAnchoredImagePosition(self.chainImage.anchor)
    }
    
    func getOpenLocketPosition() -> CGPoint
    {
        return getAnchoredImagePosition(self.openImage.anchor)
    }
    
    func getMaskFrame() -> CGRect
    {
        let pos = getAnchoredImagePosition(self.maskImage.getAnchor())
        let size = self.maskImage.getSize()
        
        return CGRectMake(pos.x, pos.y, size.width, size.height)
    }
    
    private func getAnchoredImagePosition(anchor: CGPoint) -> CGPoint
    {
        let locketPos : CGPoint = getClosedLocketPosition()
        let locketAnchor : CGPoint = closedImage.getAnchor()
        
        let chainPoint : CGPoint = CGPoint( x: locketPos.x + locketAnchor.x - anchor.x, y: locketPos.y + locketAnchor.y - anchor.y )
        
        return chainPoint
    }
    
    class func createDefaultLocket() -> Locket
    {
        let data : NSDictionary = [
            "title" : "Default",
            "open_image" : [
                "anchor_x" : 678,
                "anchor_y" : 35,
                "width" : 1187,
                "height" : 994,
                "image_full" : "http://mainbundle.app/default_open.png",
                "image_thumb" : "http://mainbundle.app/default_open.png"
            ],
            "closed_image" :[
                "anchor_x" : 492,
                "anchor_y" : 36,
                "width" : 1017,
                "height" : 994,
                "image_full" : "http://mainbundle.app/default_closed.png",
                "image_thumb" : "http://mainbundle.app/default_closed.png"
            ],
            "chain_image" :[
                "anchor_x" : 254,
                "anchor_y" : 760,
                "width" : 515,
                "height" : 770,
                "image_full" : "http://mainbundle.app/default_chain.png",
                "image_thumb" : "http://mainbundle.app/default_chain.png"
            ],
            "mask_image" :[
                "anchor_x" : 459,
                "anchor_y" : -35,
                "width" : 919,
                "height" : 814,
                "image_full" : "http://mainbundle.app/default_mask.png",
                "image_thumb" : "http://mainbundle.app/default_mask.png"
            ]
        ]
        
        return Locket(locketData: data)
    }
}

class UserLocket
{
    private (set) var title : String
    private (set) var locket : Locket
    private (set) var image : ImageAsset
    private (set) var captionText : String
    private (set) var captionFont: String
    
    init(data: NSDictionary)
    {
        self.title = data["title"] as! String
        self.locket = Locket(locketData: data["locket"] as! NSDictionary)
        self.image = ImageAsset(assetData: data["image"] as! NSDictionary)
        self.captionText = data["caption_text"] as! String
        self.captionFont = data["caption_font"] as! String
    }
    
    func setLocket(locket: Locket!)
    {
        self.locket = locket
    }
    
    class func createDefaultUserLocket() -> UserLocket
    {
        let data = [
            "title" : "My Locket",
            "locket" : Locket.createDefaultLocket().data,
            "image" : ImageAsset.createDefaultImageAsset().data,
            "caption_text" : "To cherish forever",
            "caption_font" : "Helvetica"
        ]
        
        return UserLocket(data: data)
    }
}