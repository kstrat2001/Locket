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
    func imageLoaded(_ imageView: DownloadableImageView)
}

class DownloadableImageView : UIImageView
{
    fileprivate (set) var url : URL = URL()
    
    var delegate : DownloadableImageViewDelegate?
    
    func loadImageFromUrl(_ url: URL, orientation: UIImageOrientation) {
        self.url = url
        
        if let image = DataManager.sharedManager.getCachedImage(url, orientation: orientation)
        {
            self.image = image
            self.imageLoadedCallback()
        }
        else
        {
            self.downloadImage()
        }
    }
    
    func loadImageFromUrl(_ url: URL)
    {
        self.loadImageFromUrl(url, orientation: UIImageOrientation.up)
    }
    
    fileprivate func downloadImage()
    {
        self.af_setImageWithURL(
            self.url,
            placeholderImage: nil,
            filter: nil,
            imageTransition: .None,
            completion: { response in
                switch response.result
                {
                case .Failure(let error):
                    print("Failed to download image at url: \(self.url) with error: \(error)")
                case .Success(let value):
                    if DataManager.sharedManager.cacheImage(self.url, image: value)
                    {
                        self.image = value
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
