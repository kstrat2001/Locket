//
//  DataManager.swift
//  Locket
//
//  Created by Kain Osterholt on 2/11/16.
//  Copyright © 2016 James Frost. All rights reserved.
//

import Foundation
import Alamofire

class DataManager
{
    static let sharedManager = DataManager()
    private (set) var lockets = Array<Locket>()
    
    private init()
    {
        
    }
    
    func loadAppData()
    {
        Alamofire.request(.GET, "http://api.mobilelocket.com/lockets").responseJSON()
        {
            response in
            
            switch response.result
            {
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                case .Success(let JSON):
                    let response = JSON as! NSDictionary
                    self.lockets = Locket.loadLockets(response)
            }
        }
    }
    
    func cacheImage(url: NSURL, image: UIImage) -> Bool
    {
        let path = FileManager.sharedManager.urlToFilePath(url)
        
        FileManager.sharedManager.createDirectoryForFile(path)
        
        let success = UIImagePNGRepresentation(image)?.writeToFile(path, atomically: true)
        
        return success!
    }
    
    func getCachedImage(url: NSURL) -> UIImage?
    {
        let path = FileManager.sharedManager.urlToFilePath(url)
        
        if FileManager.sharedManager.fileExists(path)
        {
            return UIImage(contentsOfFile: path)
        }
        
        return nil
    }
}