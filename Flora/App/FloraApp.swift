//
//  FloraApp.swift
//  Flora
//
//  Created by Tejas Marimuthu on 2025.10.28.
//

import SwiftUI
import CoreData

@main
struct FloraApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var repository = DataRepository()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(repository)
        }
    }
}
