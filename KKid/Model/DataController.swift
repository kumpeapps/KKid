//
//  DataController.swift
//  KKid
//
//  Created by Justin Kumpe on 8/9/20.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class DataController {

    let persistentContainer: NSPersistentContainer

    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    let backgroundContext: NSManagedObjectContext!

    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)

        backgroundContext = persistentContainer.newBackgroundContext()
    }

    func configureContexts() {
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true

        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }

    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { _, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
//            self.autoSaveViewContext()
            self.configureContexts()
            completion?()
        }
    }

//  Shared Data Controller
    static let shared = DataController(modelName: "KKid")
}

extension DataController {

// MARK: Auto Save View Context
    func autoSaveViewContext(interval: TimeInterval = 30) {
        let state = UIApplication.shared.applicationState
        guard state == .active else { return }
        Logger.log(.action, "autosaving")
        guard interval > 0 else {
            Logger.log(.error, "cannot set negative autosave inteval")
            return
        }
        if viewContext.hasChanges {
            try? viewContext.save()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext(interval: interval)
        }
    }

}
