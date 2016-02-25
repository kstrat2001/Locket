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
    let frame: CGRect!
    let title: String!
    
    init(assetData: NSDictionary!)
    {
        data = assetData
        
        let scaleFactor : CGFloat = 1.0 / 3.0
        let width: CGFloat = scaleFactor * (data["width"] as! CGFloat)
        let height: CGFloat = scaleFactor * (data["height"] as! CGFloat)
        let anchorX = scaleFactor * (data["anchor_x"] as! CGFloat)
        let anchorY = scaleFactor * (data["anchor_y"] as! CGFloat)
        
        frame = CGRectMake(anchorX, anchorY, width, height)
        title = data["title"] as! String
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
    
    class func createDefaultImageAsset() -> ImageAsset
    {
        let data : NSDictionary = [
            "title" : "default",
            "anchor_x" : 500,
            "anchor_y" : 0,
            "width" : 1000,
            "height" : 750,
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
        
        let x = 0.5 * (width - closedImage.frame.size.width)
        let y = 0.5 * (height - closedImage.frame.size.height)
        
        return CGPoint( x: x, y: y )
    }
    
    func getChainPosition() -> CGPoint
    {
        return getAnchoredImagePosition(self.chainImage.frame.origin)
    }
    
    func getOpenLocketPosition() -> CGPoint
    {
        return getAnchoredImagePosition(self.openImage.frame.origin)
    }
    
    func getMaskFrame() -> CGRect
    {
        let pos = getAnchoredImagePosition(self.maskImage.frame.origin)
        let size = self.maskImage.frame.size
        
        return CGRectMake(pos.x, pos.y, size.width, size.height)
    }
    
    func getAnchoredImagePosition(anchor: CGPoint) -> CGPoint
    {
        let locketPos : CGPoint = getClosedLocketPosition()
        let locketAnchor : CGPoint = closedImage.frame.origin
        
        let chainPoint : CGPoint = CGPoint( x: locketPos.x + locketAnchor.x - anchor.x, y: locketPos.y + locketAnchor.y - anchor.y )
        
        return chainPoint
    }
    
    class func createDefaultLocket() -> Locket
    {
        let data : NSDictionary = [
            "title" : "Default",
            "open_image" : [
                "title" : "default_open",
                "anchor_x" : 678,
                "anchor_y" : 35,
                "width" : 1187,
                "height" : 994,
                "image_full" : "http://mainbundle.app/default_open.png",
                "image_thumb" : "http://mainbundle.app/default_open.png"
            ],
            "closed_image" :[
                "title" : "default_closed",
                "anchor_x" : 492,
                "anchor_y" : 36,
                "width" : 1017,
                "height" : 994,
                "image_full" : "http://mainbundle.app/default_closed.png",
                "image_thumb" : "http://mainbundle.app/default_closed.png"
            ],
            "chain_image" :[
                "title" : "default_chain",
                "anchor_x" : 254,
                "anchor_y" : 760,
                "width" : 515,
                "height" : 770,
                "image_full" : "http://mainbundle.app/default_chain.png",
                "image_thumb" : "http://mainbundle.app/default_chain.png"
            ],
            "mask_image" :[
                "title" : "default_mask",
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
    
    func getImageFrame() -> CGRect
    {
        let pos = locket.getAnchoredImagePosition(image.frame.origin)
        return CGRectMake(pos.x, pos.y, image.frame.width, image.frame.height)
    }
    
    class func createDefaultUserLocket() -> UserLocket
    {
        let data = [
            "title" : "First Locket",
            "locket" : Locket.createDefaultLocket().data,
            "image" : ImageAsset.createDefaultImageAsset().data,
            "caption_text" : "To cherish forever",
            "caption_font" : "Helvetica"
        ]
        
        return UserLocket(data: data)
    }
}