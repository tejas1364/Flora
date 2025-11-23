//
//  MARK: - PersistenceController.swift
//  Flora
//
//  Created by Tejas Marimuthu on 2025.10.28.
//

// Core Data stack with SQLCipher encryption

import CoreData
import Foundation

class PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    // Preview instance for SwiftUI previews
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        // Create sample data for previews
        let profile = UserProfile(context: viewContext)
        profile.id = UUID()
        profile.timezone = TimeZone.current.identifier
        profile.usesMetric = Locale.current.measurementSystem == .metric
        profile.currentMode = "standard"
        profile.createdAt = Date()
        profile.updatedAt = Date()
        
        do {
            try viewContext.save()
        } catch {
            fatalError("Preview data creation failed: \(error)")
        }
        
        return controller
    }()
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Flora")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } else {
            // Setup encrypted store
            setupEncryptedStore()
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                // In production, handle this more gracefully
                fatalError("Core Data store failed to load: \(error)")
            }
        }
        
        // Configure merge policy
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    private func setupEncryptedStore() {
        guard let storeURL = container.persistentStoreDescriptions.first?.url else {
            return
        }
        
        // Get or create encryption key
        let encryptionKey = SecurityManager.shared.getOrCreateEncryptionKey()
        
        // Configure store with encryption
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        storeDescription.setOption(encryptionKey as NSString,
                                   forKey: "passphrase")
        storeDescription.setOption(FileProtectionType.complete as NSObject,
                                   forKey: NSPersistentStoreFileProtectionKey)
        
        container.persistentStoreDescriptions = [storeDescription]
    }
    
    // MARK: - Save Context
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Handle error appropriately in production
                let nsError = error as NSError
                print("Failed to save context: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // MARK: - Background Context Operations
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        container.performBackgroundTask(block)
    }
    
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
}
