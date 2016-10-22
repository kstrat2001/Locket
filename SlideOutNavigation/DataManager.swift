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
    
    fileprivate (set) var locketSkins : [LocketSkinEntity] = [LocketSkinEntity]()
    
    let managedObjectContext: NSManagedObjectContext!
    let managedObjectModel: NSManagedObjectModel!
    let persistantStoreCoordinator: NSPersistentStoreCoordinator!
    
    fileprivate init()
    {
        let modelURL = Bundle.main.url(forResource: "LocketModel", withExtension: "momd")
        self.managedObjectModel = NSManagedObjectModel(contentsOf: modelURL!)
        
        self.persistantStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        let fileString = "file:///" + FileManager.sharedManager.docRoot
        let storeURL = URL(string: fileString)?.appendingPathComponent("Locket.sqlite")
        
        do {
            try self.persistantStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
        }
        catch {
            print("Failed to create database store, error: \(error)")
            abort()
        }
        
        self.managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        self.managedObjectContext.persistentStoreCoordinator = self.persistantStoreCoordinator
    }
    
    func fetchAll(_ entityName: String) -> [AnyObject]
    {
        let fetchRequest = NSFetchRequest()
        let entityDesc = NSEntityDescription.entity(forEntityName: entityName, in: self.managedObjectContext)
        fetchRequest.entity = entityDesc
        
        do {
            let result = try managedObjectContext.fetch(fetchRequest)
            return result
        }
        catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        
        return [AnyObject]()
    }
    
    func fetchWithId(_ entityName: String, id: NSNumber ) -> [AnyObject]
    {
        let fetchRequest = NSFetchRequest()
        let entityDesc = NSEntityDescription.entity(forEntityName: entityName, in: self.managedObjectContext)
        fetchRequest.entity = entityDesc
        
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let result = try managedObjectContext.fetch(fetchRequest)
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
    
    fileprivate func downloadLocketSkins()
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
    
    func deleteRecord(_ record: NSManagedObject) {
        self.managedObjectContext.delete(record)
        self.saveAllRecords()
    }
    
    func cacheImage(_ url: URL, image: UIImage) -> Bool
    {
        let path = FileManager.sharedManager.urlToFilePath(url)
        
        FileManager.sharedManager.createDirectoryForFile(path)
        
        let success = (try? UIImagePNGRepresentation(image)?.write(to: URL(fileURLWithPath: path), options: [.atomic])) != nil
        
        return success!
    }
    
    func getCachedImage(_ url: URL, orientation: UIImageOrientation ) -> UIImage?
    {
        let path = FileManager.sharedManager.urlToFilePath(url)
        
        if FileManager.sharedManager.fileExists(path)
        {
            let image = UIImage(contentsOfFile: path)
            return UIImage(cgImage: image!.cgImage!, scale: 1.0, orientation: orientation)
        }
        
        return nil
    }
    
    func deleteCachedFile(_ url: URL)
    {
        let path = FileManager.sharedManager.urlToFilePath(url)
        
        if FileManager.sharedManager.fileExists(path) {
            FileManager.sharedManager.deleteFile(path)
        }
    }
}
