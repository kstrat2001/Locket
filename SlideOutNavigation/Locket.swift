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
    private let _data: NSDictionary!
    private let _anchor: CGPoint!
    private let _size: CGSize!
    
    init(assetData: NSDictionary!)
    {
        _data = assetData
        
        let scaleFactor = (UIScreen.mainScreen().scale / 3.0) / 3.0
        let width: CGFloat = scaleFactor * (_data["width"] as! CGFloat)
        let height: CGFloat = scaleFactor * (_data["height"] as! CGFloat)
        
        _size = CGSize( width: width, height: height )
        
        let anchorX = scaleFactor * (_data["anchor_x"] as! CGFloat)
        let anchorY = scaleFactor * (_data["anchor_y"] as! CGFloat)
        
        _anchor = CGPoint( x: anchorX, y: anchorY )
        
        print("thumb path: \(getThumbFilePath())")
    }
    
    func getTitle() -> String
    {
        return _data["title"] as! String
    }
    
    func getThumbUrl() -> NSURL
    {
        let thumbStr : String = _data["image_thumb"] as! String
        return NSURL(string: thumbStr)!
    }
    
    func getThumbFilePath() -> String
    {
        let url = getThumbUrl();
        
        return String(url.path)
    }
    
    func getImageUrl() -> NSURL
    {
        let imageStr = _data["image_full"] as! String
        return NSURL(string: imageStr)!
    }
    
    func getAnchor() -> CGPoint
    {
        return _anchor
    }
    
    func getSize() -> CGSize
    {
        return _size
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
        let locketPos : CGPoint = getClosedLocketPosition()
        let locketAnchor : CGPoint = closedImage.getAnchor()
        let chainAnchor : CGPoint = chainImage.getAnchor()
        
        let chainPoint : CGPoint = CGPoint( x: locketPos.x + locketAnchor.x - chainAnchor.x, y: locketPos.y + locketAnchor.y - chainAnchor.y )
        
        return chainPoint
    }
    
    func getOpenLocketPosition() -> CGPoint
    {
        let locketPos : CGPoint = getClosedLocketPosition()
        let locketAnchor : CGPoint = closedImage.getAnchor()
        let openAnchor : CGPoint = openImage.getAnchor()
        
        let chainPoint : CGPoint = CGPoint( x: locketPos.x + locketAnchor.x - openAnchor.x, y: locketPos.y + locketAnchor.y - openAnchor.y )
        
        return chainPoint
    }
}