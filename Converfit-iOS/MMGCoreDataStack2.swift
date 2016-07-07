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
    var options: Dictionary<NSObject,AnyObject>?
    
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
            "storeURL: \(storeURL)\n"
    }
    
    var modelURL : URL {
        return Bundle.main.urlForResource(self.modelName, withExtension: "momd")!
    }
    
    var storeURL : URL {
        let storePaths = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
        let storePath = String(storePaths.first!) as NSString
        let fileManager = FileManager.default
        
        do {
            try fileManager.createDirectory(atPath: storePath as String, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print("Error creating storePath \(storePath): \(error)")
        }
        let sqliteFilePath = storePath.appendingPathComponent(storeName + ".sqlite")
        return URL(fileURLWithPath: sqliteFilePath)
    }
    
    lazy var model : NSManagedObjectModel = NSManagedObjectModel(contentsOf: self.modelURL)!
    
    var store : NSPersistentStore?
    
    lazy var coordinator : NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.model)
        do {
            self.store = try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil,
                at: self.storeURL,
                options: self.options)
        } catch var error as NSError {
            print("Store Error: \(error)")
            self.store = nil
        } catch {
            fatalError()
        }
        return coordinator
        }()
    
    lazy var context : NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
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
