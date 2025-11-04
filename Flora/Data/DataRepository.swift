//
//  MARK: - DataRepository.swift
//  Flora
//
//  Created by Tejas Marimuthu on 2025.11.04.
//

// Clean API for data access

import CoreData
import Combine

class DataRepository: ObservableObject {
    private let persistenceController: PersistenceController
    private var viewContext: NSManagedObjectContext {
        persistenceController.container.viewContext
    }
    
    init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
    }
    
    // MARK: - User Profile
    func getUserProfile() -> UserProfile? {
        let request = UserProfile.fetchRequest()
        request.fetchLimit = 1
        
        return try? viewContext.fetch(request).first
    }
    
    func createOrUpdateUserProfile(
        birthYear: Int? = nil,
        mode: String? = nil,
        usesMetric: Bool? = nil
    ) {
        let profile = getUserProfile() ?? UserProfile(context: viewContext)
        
        if profile.id == UUID(uuidString: "00000000-0000-0000-0000-000000000000") {
            profile.id = UUID()
            profile.createdAt = Date()
            profile.timezone = TimeZone.current.identifier
        }
        
        if let birthYear = birthYear {
            profile.birthYear = Int16(birthYear)
        }
        if let mode = mode {
            profile.currentMode = mode
        }
        if let usesMetric = usesMetric {
            profile.usesMetric = usesMetric
        }
        
        profile.updatedAt = Date()
        persistenceController.save()
    }
    
    // MARK: - Cycles
    func getCurrentCycle() -> Cycle? {
        let request = Cycle.fetchRequest()
        request.predicate = NSPredicate(format: "endDate == nil")
        request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
        request.fetchLimit = 1
        
        return try? viewContext.fetch(request).first
    }
    
    func getAllCycles(limit: Int? = nil) -> [Cycle] {
        let request = Cycle.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
        if let limit = limit {
            request.fetchLimit = limit
        }
        
        return (try? viewContext.fetch(request)) ?? []
    }
    
    func createCycle(startDate: Date) -> Cycle {
        let cycle = Cycle(context: viewContext)
        cycle.id = UUID()
        cycle.startDate = startDate
        cycle.createdAt = Date()
        
        persistenceController.save()
        return cycle
    }
    
    // MARK: - Period Events
    func logPeriodEvent(
        date: Date,
        flowLevel: Int,
        isSpotting: Bool,
        notes: String? = nil
    ) {
        let event = PeriodEvent(context: viewContext)
        event.id = UUID()
        event.date = date
        event.flowLevel = Int16(flowLevel)
        event.isSpotting = isSpotting
        event.notes = notes
        event.source = "manual"
        event.createdAt = Date()
        
        // Associate with current or new cycle
        if let currentCycle = getCurrentCycle() {
            event.cycle = currentCycle
        } else {
            let newCycle = createCycle(startDate: date)
            event.cycle = newCycle
        }
        
        persistenceController.save()
    }
    
    // MARK: - Symptoms
    func logSymptom(
        dateTime: Date,
        symptomType: String,
        intensity: Int,
        notes: String? = nil,
        tags: [String]? = nil
    ) {
        let symptom = SymptomLog(context: viewContext)
        symptom.id = UUID()
        symptom.dateTime = dateTime
        symptom.symptomType = symptomType
        symptom.intensity = Int16(intensity)
        symptom.notes = notes
        
        if let tags = tags {
            symptom.tags = try? JSONEncoder().encode(tags).base64EncodedString()
        }
        
        symptom.createdAt = Date()
        symptom.cycle = getCurrentCycle()
        
        persistenceController.save()
    }
    
    // MARK: - Vitals
    func logVitals(
        dateTime: Date,
        bbt: Double? = nil,
        weight: Double? = nil,
        restingHeartRate: Int? = nil,
        sleepHours: Double? = nil,
        sleepQuality: Int? = nil
    ) {
        let vitals = Vitals(context: viewContext)
        vitals.id = UUID()
        vitals.dateTime = dateTime
        vitals.bbt = bbt ?? 0
        vitals.weight = weight ?? 0
        vitals.restingHeartRate = Int16(restingHeartRate ?? 0)
        vitals.sleepHours = sleepHours ?? 0
        vitals.sleepQuality = Int16(sleepQuality ?? 0)
        vitals.createdAt = Date()
        vitals.cycle = getCurrentCycle()
        
        persistenceController.save()
    }
}
