//
//  MARK: - CoreDataModels.swift
//  Flora
//
//  Created by Tejas Marimuthu on 2025.11.04.
//

// Core Data entity definitions

// MARK: - CoreDataModels.swift
// Clean Core Data model definitions for Flora

import Foundation
import CoreData

// MARK: - UserProfile
@objc(UserProfile)
public class UserProfile: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var birthYear: Int16
    @NSManaged public var timezone: String
    @NSManaged public var usesMetric: Bool
    @NSManaged public var currentMode: String
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var healthKitEnabled: Bool
    @NSManaged public var appLockEnabled: Bool
    @NSManaged public var biometricAuthEnabled: Bool
}

extension UserProfile {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserProfile> {
        return NSFetchRequest<UserProfile>(entityName: "UserProfile")
    }
}

// MARK: - Cycle
@objc(Cycle)
public class Cycle: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var startDate: Date
    @NSManaged public var endDate: Date?
    @NSManaged public var averageFlowLevel: Int16
    @NSManaged public var notes: String?
    @NSManaged public var cycleLength: Int16
    @NSManaged public var createdAt: Date
    
    @NSManaged public var periodEvents: NSSet?
    @NSManaged public var symptoms: NSSet?
    @NSManaged public var vitals: NSSet?
}

extension Cycle {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Cycle> {
        return NSFetchRequest<Cycle>(entityName: "Cycle")
    }
    
    public var periodEventsArray: [PeriodEvent] {
        let set = periodEvents as? Set<PeriodEvent> ?? []
        return set.sorted { $0.date < $1.date }
    }
    
    public var symptomsArray: [SymptomLog] {
        let set = symptoms as? Set<SymptomLog> ?? []
        return set.sorted { $0.dateTime < $1.dateTime }
    }
    
    public var vitalsArray: [Vitals] {
        let set = vitals as? Set<Vitals> ?? []
        return set.sorted { $0.dateTime < $1.dateTime }
    }
}

// MARK: - PeriodEvent
@objc(PeriodEvent)
public class PeriodEvent: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var flowLevel: Int16
    @NSManaged public var isSpotting: Bool
    @NSManaged public var source: String
    @NSManaged public var notes: String?
    @NSManaged public var createdAt: Date
    
    @NSManaged public var cycle: Cycle?
}

extension PeriodEvent {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PeriodEvent> {
        return NSFetchRequest<PeriodEvent>(entityName: "PeriodEvent")
    }
}

// MARK: - SymptomLog
@objc(SymptomLog)
public class SymptomLog: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var dateTime: Date
    @NSManaged public var symptomType: String
    @NSManaged public var intensity: Int16
    @NSManaged public var notes: String?
    @NSManaged public var tags: String?
    @NSManaged public var createdAt: Date
    
    @NSManaged public var cycle: Cycle?
}

extension SymptomLog {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SymptomLog> {
        return NSFetchRequest<SymptomLog>(entityName: "SymptomLog")
    }
}

// MARK: - Vitals
@objc(Vitals)
public class Vitals: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var dateTime: Date
    @NSManaged public var bbt: Double
    @NSManaged public var weight: Double
    @NSManaged public var restingHeartRate: Int16
    @NSManaged public var sleepHours: Double
    @NSManaged public var sleepQuality: Int16
    @NSManaged public var createdAt: Date
    
    @NSManaged public var cycle: Cycle?
}

extension Vitals {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Vitals> {
        return NSFetchRequest<Vitals>(entityName: "Vitals")
    }
}

// MARK: - SexActivity
@objc(SexActivity)
public class SexActivity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var dateTime: Date
    @NSManaged public var isProtected: Bool
    @NSManaged public var partnerTag: String?
    @NSManaged public var notes: String?
    @NSManaged public var createdAt: Date
    
    @NSManaged public var cycle: Cycle?
}

extension SexActivity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SexActivity> {
        return NSFetchRequest<SexActivity>(entityName: "SexActivity")
    }
}

// MARK: - BirthControl
@objc(BirthControl)
public class BirthControl: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var type: String
    @NSManaged public var name: String?
    @NSManaged public var startDate: Date
    @NSManaged public var endDate: Date?
    @NSManaged public var schedule: String?
    @NSManaged public var isActive: Bool
    @NSManaged public var createdAt: Date
    
    @NSManaged public var adherenceLogs: NSSet?
}

extension BirthControl {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<BirthControl> {
        return NSFetchRequest<BirthControl>(entityName: "BirthControl")
    }
}

// MARK: - Medication
@objc(Medication)
public class Medication: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var dosage: String?
    @NSManaged public var schedule: String?
    @NSManaged public var isPRN: Bool
    @NSManaged public var isActive: Bool
    @NSManaged public var createdAt: Date
    
    @NSManaged public var adherenceLogs: NSSet?
}

extension Medication {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Medication> {
        return NSFetchRequest<Medication>(entityName: "Medication")
    }
}

// MARK: - AdherenceLog
@objc(AdherenceLog)
public class AdherenceLog: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var dateTime: Date
    @NSManaged public var taken: Bool
    @NSManaged public var skipped: Bool
    @NSManaged public var notes: String?
    @NSManaged public var createdAt: Date
    
    @NSManaged public var birthControl: BirthControl?
    @NSManaged public var medication: Medication?
}

extension AdherenceLog {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<AdherenceLog> {
        return NSFetchRequest<AdherenceLog>(entityName: "AdherenceLog")
    }
}

// MARK: - PredictionSnapshot
@objc(PredictionSnapshot)
public class PredictionSnapshot: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var computedAt: Date
    @NSManaged public var cycleDay: Int16
    @NSManaged public var nextPeriodStart: Date
    @NSManaged public var nextPeriodEnd: Date
    @NSManaged public var nextPeriodStartMin: Date
    @NSManaged public var nextPeriodStartMax: Date
    @NSManaged public var fertileWindowStart: Date?
    @NSManaged public var fertileWindowEnd: Date?
    @NSManaged public var ovulationEstimate: Date?
    @NSManaged public var confidence: Double
    @NSManaged public var rationale: String?
    @NSManaged public var isIrregular: Bool
}

extension PredictionSnapshot {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PredictionSnapshot> {
        return NSFetchRequest<PredictionSnapshot>(entityName: "PredictionSnapshot")
    }
}

// MARK: - AppSettings
@objc(AppSettings)
public class AppSettings: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var theme: String
    @NSManaged public var accentColor: String
    @NSManaged public var notificationsEnabled: Bool
    @NSManaged public var quietHoursStart: Date?
    @NSManaged public var quietHoursEnd: Date?
    @NSManaged public var remindersPeriod: Bool
    @NSManaged public var remindersBirthControl: Bool
    @NSManaged public var remindersMedication: Bool
    @NSManaged public var remindersBBT: Bool
    @NSManaged public var updatedAt: Date
}

extension AppSettings {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<AppSettings> {
        return NSFetchRequest<AppSettings>(entityName: "AppSettings")
    }
}
