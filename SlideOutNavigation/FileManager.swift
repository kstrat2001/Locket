//
//  FileManager.swift
//  Locket
//
//  Created by Kain Osterholt on 2/17/16.
//  Copyright © 2016 Kain Osterholt. All rights reserved.
//

import Foundation

class FileManager
{
    static let sharedManager = FileManager()
    
    fileprivate(set) var docRoot : String = ""
    
    fileprivate init()
    {
        self.setupDocRoot()
    }
    
    fileprivate func setupDocRoot()
    {
        let paths : NSArray = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        
        self.docRoot = paths.object(at: 0) as! String;
    }
    
    func urlToFilePath( _ url : URL ) -> String
    {
        if url.host?.compare(gMainBundleHost) == ComparisonResult.orderedSame
        {
            let resource = NSString(string: url.path).deletingPathExtension.replacingOccurrences(of: "/", with: "")
            let ext = NSString(string: url.path).pathExtension
            
            let path = Bundle.main.path(forResource: resource, ofType: ext)
            
            if path == nil {
                return ""
            }
            else {
                return path!
            }
        }
        else if url.host?.compare(gFileHost) == ComparisonResult.orderedSame {
            
            return self.docRoot + url.path
        }
        
        return self.docRoot + url.path
    }
    
    func fileExists(_ path : String) -> Bool
    {
        return Foundation.FileManager.default.fileExists(atPath: path)
    }
    
    func fileIsCached(_ url: URL) -> Bool
    {
        return fileExists(self.urlToFilePath(url))
    }
    
    func createDirectoryForFile(_ filePath: String)
    {
        let dir: NSString = NSString(string: filePath).deletingLastPathComponent as NSString
        
        if fileExists(String(dir)) == false
        {
            createDirectory(String(dir))
        }
    }
    
    func deleteFile(_ path : String) -> Bool
    {
        let mgr = Foundation.FileManager.default
        
        var success = true
        
        do
        {
            try mgr.removeItem(atPath: path)
        }
        catch
        {
            print("deleteFile failed to delete \(path), error: \(error)")
            success = false
        }
        
        return success
    }
    
    func deleteFilesAtPath(_ path: String) -> Bool
    {
        var success = true;
        
        do {
            let files = try Foundation.FileManager.default.contentsOfDirectory(atPath: path)
            
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
    
    func createDirectory(_ path: String) -> Bool
    {
        do {
            try Foundation.FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        }
        catch {
            return false;
        }
        
        return true
    }
    
}
