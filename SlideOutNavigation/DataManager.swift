//
//  DataManager.swift
//  Locket
//
//  Created by Kain Osterholt on 2/11/16.
//  Copyright © 2016 James Frost. All rights reserved.
//

import Foundation
import Alamofire
import CoreData

class DataManager
{
    static let sharedManager = DataManager()
    
    private (set) var locketSkins : [LocketSkinEntity] = [LocketSkinEntity]()
    
    let managedObjectContext: NSManagedObjectContext!
    let managedObjectModel: NSManagedObjectModel!
    let persistantStoreCoordinator: NSPersistentStoreCoordinator!
    
    private init()
    {
        let modelURL = NSBundle.mainBundle().URLForResource("LocketModel", withExtension: "momd")
        self.managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL!)
        
        self.persistantStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        let fileString = "file:///" + FileManager.sharedManager.docRoot
        let storeURL = NSURL(string: fileString)?.URLByAppendingPathComponent("Locket.sqlite")
        
        do {
            try self.persistantStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
        }
        catch {
            print("Failed to create database store, error: \(error)")
            abort()
        }
        
        self.managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        self.managedObjectContext.persistentStoreCoordinator = self.persistantStoreCoordinator
    }
    
    func fetchAll(entityName: String) -> [AnyObject]
    {
        let fetchRequest = NSFetchRequest()
        let entityDesc = NSEntityDescription.entityForName(entityName, inManagedObjectContext: self.managedObjectContext)
        fetchRequest.entity = entityDesc
        
        do {
            let result = try managedObjectContext.executeFetchRequest(fetchRequest)
            return result
        }
        catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        
        return [AnyObject]()
    }
    
    func fetchWithId(entityName: String, id: NSNumber ) -> [AnyObject]
    {
        let fetchRequest = NSFetchRequest()
        let entityDesc = NSEntityDescription.entityForName(entityName, inManagedObjectContext: self.managedObjectContext)
        fetchRequest.entity = entityDesc
        
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let result = try managedObjectContext.executeFetchRequest(fetchRequest)
            return result
        }
        catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        
        return [AnyObject]()
    }
    
    func saveAllRecords()
    {
        do {
            try self.managedObjectContext.save()
        } catch {
            print("Error saving records: \(error)")
        }
    }
    
    func syncAppData()
    {
        LocketSkinEntity.createWithData(gDefaultLocketData)
        
        locketSkins = self.fetchAll("LocketSkinEntity") as! [LocketSkinEntity]
        
        self.downloadLocketSkins()
    }
    
    private func downloadLocketSkins()
    {
        Alamofire.request(.GET, gServerApiGetLockets).responseJSON()
        {
            response in
            
            switch response.result
            {
            case .Failure(let error):
                print("Request failed with error: \(error)")
            case .Success(let JSON):
                let response = JSON as! NSDictionary

                let lockets = response["lockets"] as! Array<NSDictionary>
                
                var ids = [ NSNumber : NSNumber? ]()
                ids[gDefaultLocketSkinID] = gDefaultLocketSkinID
                
                for locket in lockets {
                    ids[locket["id"] as! NSNumber] = locket["id"] as? NSNumber
                    LocketSkinEntity.createWithData(locket)
                }
                
                for skin in self.locketSkins {
                    if ids[skin.id] == nil && !SettingsManager.sharedManager.locketSkinInUse(skin) {
                        print("Deleting deleted skin: \(skin.title)")
                        self.deleteRecord(skin)
                    }
                }
                
                self.locketSkins = self.fetchAll("LocketSkinEntity") as! [LocketSkinEntity]
            }
        }
    }
    
    func deleteRecord(record: NSManagedObject) {
        self.managedObjectContext.deleteObject(record)
        self.saveAllRecords()
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
    
    func deleteCachedFile(url: NSURL)
    {
        let path = FileManager.sharedManager.urlToFilePath(url)
        
        if FileManager.sharedManager.fileExists(path) {
            FileManager.sharedManager.deleteFile(path)
        }
    }
}