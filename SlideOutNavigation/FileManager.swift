//
//  FileManager.swift
//  Locket
//
//  Created by Kain Osterholt on 2/17/16.
//  Copyright © 2016 James Frost. All rights reserved.
//

import Foundation

class FileManager
{
    static let sharedManager = FileManager()
    
    private(set) var docRoot : String = ""
    
    private init()
    {
        self.setupDocRoot()
    }
    
    private func setupDocRoot()
    {
        let paths : NSArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
        self.docRoot = paths.objectAtIndex(0) as! String;
    }
    
    func urlToFilePath( url : NSURL ) -> String
    {
        if url.host?.compare(gMainBundleHost) == NSComparisonResult.OrderedSame
        {
            let resource = NSString(string: url.path!).stringByDeletingPathExtension.stringByReplacingOccurrencesOfString("/", withString: "")
            let ext = NSString(string: url.path!).pathExtension
            
            let path = NSBundle.mainBundle().pathForResource(resource, ofType: ext)
            
            if path == nil {
                return ""
            }
            else {
                return path!
            }
        }
        else if url.host?.compare(gFileHost) == NSComparisonResult.OrderedSame {
            
            return self.docRoot + url.path!
        }
        
        return self.docRoot + url.path!
    }
    
    func fileExists(path : String) -> Bool
    {
        return NSFileManager.defaultManager().fileExistsAtPath(path)
    }
    
    func fileIsCached(url: NSURL) -> Bool
    {
        return fileExists(self.urlToFilePath(url))
    }
    
    func createDirectoryForFile(filePath: String)
    {
        let dir: NSString = NSString(string: filePath).stringByDeletingLastPathComponent
        
        if fileExists(String(dir)) == false
        {
            createDirectory(String(dir))
        }
    }
    
    func deleteFile(path : String) -> Bool
    {
        let mgr = NSFileManager.defaultManager()
        
        var success = true
        
        do
        {
            try mgr.removeItemAtPath(path)
        }
        catch
        {
            print("deleteFile failed to delete \(path), error: \(error)")
            success = false
        }
        
        return success
    }
    
    func deleteFilesAtPath(path: String) -> Bool
    {
        var success = true;
        
        do {
            let files = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(path)
            
            for file in files
            {
                success = success && self.deleteFile(file)
            }
        }
        catch {
            print("deleteFiilesAtPath failed in \(path), error: \(error)")
            success = false
        }

        return success
    }
    
    func createDirectory(path: String) -> Bool
    {
        do {
            try NSFileManager.defaultManager().createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil)
        }
        catch {
            return false;
        }
        
        return true
    }
    
}