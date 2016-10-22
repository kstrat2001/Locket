//
//  DownloadableImageView.swift
//  Locket
//
//  Created by Kain Osterholt on 2/21/16.
//  Copyright © 2016 Kain Osterholt. All rights reserved.
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
    fileprivate (set) var url : URL = URL(string: "http://www.mobilelocket.com")!
    
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
        self.af_setImage(
            withURL: self.url,
            placeholderImage: nil,
            filter: nil,
            imageTransition: .noTransition,
            completion: { response in
                switch response.result
                {
                case .failure(let error):
                    print("Failed to download image at url: \(self.url) with error: \(error)")
                case .success(let value):
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
