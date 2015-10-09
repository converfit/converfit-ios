//
//  MMGCoreDataStack2.swift
//  CitiousManager-IOs
//
//  Created by Manuel Martinez Gomez on 8/10/15.
//  Copyright © 2015 Citious Team. All rights reserved.
//

import Foundation
import CoreData

class MMGCoreDataStack2: CustomStringConvertible {
    var modelName : String
    var storeName : String
    var options: NSDictionary?
    
    init(modelName: String) {
        self.modelName = modelName
        self.storeName = modelName
        self.options = [NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true]
    }
    
    var description : String
        {
            return "context: \(context)\n" +
                "modelName: \(modelName)" +
                //        "model: \(model.entityVersionHashesByName)\n" +
                //        "coordinator: \(coordinator)\n" +
            "storeURL: \(storeURL)\n"
            //        "store: \(store)"
    }
    
    var modelURL : NSURL {
        return NSBundle.mainBundle().URLForResource(self.modelName, withExtension: "momd")!
    }
    
    var storeURL : NSURL {
        let storePaths = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true)
        let storePath = String(storePaths.first!) as NSString
        let fileManager = NSFileManager.defaultManager()
        
        do {
            try fileManager.createDirectoryAtPath(storePath as String, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print("Error creating storePath \(storePath): \(error)")
        }
        let sqliteFilePath = storePath.stringByAppendingPathComponent(storeName + ".sqlite")
        return NSURL(fileURLWithPath: sqliteFilePath)
    }
    
    lazy var model : NSManagedObjectModel = NSManagedObjectModel(contentsOfURL: self.modelURL)!
    
    var store : NSPersistentStore?
    
    lazy var coordinator : NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.model)
        do {
            self.store = try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil,
                URL: self.storeURL,
                options: nil)
        } catch var error as NSError {
            print("Store Error: \(error)")
            self.store = nil
        } catch {
            fatalError()
        }
        return coordinator
        }()
    
    lazy var context : NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = self.coordinator
        return context
        }()
    
    func saveContext () {
        if self.context.hasChanges
        {
            do {
                try self.context.save()
            } catch let error as NSError {
                print("Error saving context: \(error)")
            }
        }
    }
}
