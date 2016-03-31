//
//  DownloadableImageView.swift
//  Locket
//
//  Created by Kain Osterholt on 2/21/16.
//  Copyright © 2016 James Frost. All rights reserved.
//

import Foundation
import UIKit
import AlamofireImage

protocol DownloadableImageViewDelegate
{
    func imageLoaded(imageView: DownloadableImageView)
}

class DownloadableImageView : UIImageView
{
    private (set) var url : NSURL = NSURL()
    
    var delegate : DownloadableImageViewDelegate?
    
    class func createWithUrl(url: NSURL) -> DownloadableImageView
    {
        let imgView = DownloadableImageView()
        imgView.loadImageFromUrl(url)
        
        return imgView
    }
    
    func loadImageFromUrl(url: NSURL)
    {
        self.url = url
        
        if let image = DataManager.sharedManager.getCachedImage(url)
        {
            self.image = image
            self.imageLoadedCallback()
        }
        else
        {
            self.downloadImage()
        }
    }
    
    private func downloadImage()
    {
        self.af_setImageWithURL(
            self.url,
            placeholderImage: nil,
            filter: nil,
            imageTransition: .CrossDissolve(0.5),
            completion: { response in
                switch response.result
                {
                case .Failure(let error):
                    print("Failed to download image at url: \(self.url) with error: \(error)")
                case .Success(let value):
                    if DataManager.sharedManager.cacheImage(self.url, image: value)
                    {
                        self.imageLoadedCallback()
                    }
                    else
                    {
                        print("Failed to cache image at url: \(self.url)")
                    }
                }
            }
        )
    }
    
    func imageLoadedCallback()
    {
        self.delegate?.imageLoaded(self)
    }
    
}
