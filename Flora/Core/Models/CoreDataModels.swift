//
//  MARK: - CoreDataModels.swift
//  Flora
//
//  Created by Tejas Marimuthu on 2025.11.04.
//

// Core Data entity definitions

import Foundation
import CoreData

// MARK: - UserProfile
@objc(UserProfile)
public class UserProfile: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var birthYear: Int16  // 0 if not provided
    @NSManaged public var timezone: String
    @NSManaged public var usesMetric: Bool
    @NSManaged public var currentMode: String  // "standard", "ttc", "pregnancy", "postpartum", "perimenopause"
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    
    // Privacy flags
    @NSManaged public var healthKitEnabled: Bool
    @NSManaged public var appLockEnabled: Bool
    @NSManaged public var biometricAuthEnabled: Bool
}

// MARK: - Cycle
@objc(Cycle)
public class Cycle: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var startDate: Date
    @NSManaged public var endDate: Date?  // nil until next period detected
    @NSManaged public var averageFlowLevel: Int16  // 0=spotting, 1=light, 2=medium, 3=heavy
    @NSManaged public var notes: String?
    @NSManaged public var cycleLength: Int16  // computed when ended
    @NSManaged public var createdAt: Date
    
    @NSManaged public var periodEvents: NSSet?
    @NSManaged public var symptoms: NSSet?
    @NSManaged public var vitals: NSSet?
    @NSManaged public var sexActivities: NSSet?
}

// MARK: - PeriodEvent
@objc(PeriodEvent)
public class PeriodEvent: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var flowLevel: Int16  // 0=spotting, 1=light, 2=medium, 3=heavy
    @NSManaged public var isSpotting: Bool
    @NSManaged public var source: String  // "manual" or "auto"
    @NSManaged public var notes: String?
    @NSManaged public var createdAt: Date
    
    @NSManaged public var cycle: Cycle?
}

// MARK: - SymptomLog
@objc(SymptomLog)
public class SymptomLog: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var dateTime: Date
    @NSManaged public var symptomType: String  // "cramps", "headache", "bloating", etc.
    @NSManaged public var intensity: Int16  // 0-3
    @NSManaged public var notes: String?
    @NSManaged public var tags: String?  // JSON array of mood tags
    @NSManaged public var createdAt: Date
    
    @NSManaged public var cycle: Cycle?
}

// MARK: - Vitals
@objc(Vitals)
public class Vitals: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var dateTime: Date
    @NSManaged public var bbt: Double  // Basal Body Temperature in Celsius (0 if not measured)
    @NSManaged public var weight: Double  // in kg (0 if not measured)
    @NSManaged public var restingHeartRate: Int16  // 0 if not measured
    @NSManaged public var sleepHours: Double  // 0 if not measured
    @NSManaged public var sleepQuality: Int16  // 0=not tracked, 1=poor, 2=fair, 3=good, 4=excellent
    @NSManaged public var createdAt: Date
    
    @NSManaged public var cycle: Cycle?
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

// MARK: - BirthControl
@objc(BirthControl)
public class BirthControl: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var type: String  // "pill", "iud", "ring", "shot", "implant", "patch", "emergency"
    @NSManaged public var name: String?
    @NSManaged public var startDate: Date
    @NSManaged public var endDate: Date?
    @NSManaged public var schedule: String?  // JSON schedule data
    @NSManaged public var isActive: Bool
    @NSManaged public var createdAt: Date
    
    @NSManaged public var adherenceLogs: NSSet?
}

// MARK: - Medication
@objc(Medication)
public class Medication: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var dosage: String?
    @NSManaged public var schedule: String?  // JSON schedule data
    @NSManaged public var isPRN: Bool  // as-needed vs scheduled
    @NSManaged public var isActive: Bool
    @NSManaged public var createdAt: Date
    
    @NSManaged public var adherenceLogs: NSSet?
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

// MARK: - PredictionSnapshot
@objc(PredictionSnapshot)
public class PredictionSnapshot: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var computedAt: Date
    @NSManaged public var cycleDay: Int16
    @NSManaged public var nextPeriodStart: Date
    @NSManaged public var nextPeriodEnd: Date
    @NSManaged public var nextPeriodStartMin: Date  // confidence band minimum
    @NSManaged public var nextPeriodStartMax: Date  // confidence band maximum
    @NSManaged public var fertileWindowStart: Date?
    @NSManaged public var fertileWindowEnd: Date?
    @NSManaged public var ovulationEstimate: Date?
    @NSManaged public var confidence: Double  // 0.0 to 1.0
    @NSManaged public var rationale: String?  // JSON explanation
    @NSManaged public var isIrregular: Bool
}

// MARK: - AppSettings
@objc(AppSettings)
public class AppSettings: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var theme: String  // "auto", "light", "dark"
    @NSManaged public var accentColor: String  // "rose", "coral", "lavender", "sage"
    @NSManaged public var notificationsEnabled: Bool
    @NSManaged public var quietHoursStart: Date?
    @NSManaged public var quietHoursEnd: Date?
    @NSManaged public var remindersPeriod: Bool
    @NSManaged public var remindersBirthControl: Bool
    @NSManaged public var remindersMedication: Bool
    @NSManaged public var remindersBBT: Bool
    @NSManaged public var updatedAt: Date
}

// MARK: - Core Data Model Extensions

extension UserProfile {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserProfile> {
        return NSFetchRequest<UserProfile>(entityName: "UserProfile")
    }
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
}

extension PeriodEvent {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PeriodEvent> {
        return NSFetchRequest<PeriodEvent>(entityName: "PeriodEvent")
    }
}

extension SymptomLog {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SymptomLog> {
        return NSFetchRequest<SymptomLog>(entityName: "SymptomLog")
    }
}

extension Vitals {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Vitals> {
        return NSFetchRequest<Vitals>(entityName: "Vitals")
    }
}

extension SexActivity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SexActivity> {
        return NSFetchRequest<SexActivity>(entityName: "SexActivity")
    }
}

extension BirthControl {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<BirthControl> {
        return NSFetchRequest<BirthControl>(entityName: "BirthControl")
    }
}

extension Medication {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Medication> {
        return NSFetchRequest<Medication>(entityName: "Medication")
    }
}

extension AdherenceLog {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<AdherenceLog> {
        return NSFetchRequest<AdherenceLog>(entityName: "AdherenceLog")
    }
}

extension PredictionSnapshot {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PredictionSnapshot> {
        return NSFetchRequest<PredictionSnapshot>(entityName: "PredictionSnapshot")
    }
}

extension AppSettings {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<AppSettings> {
        return NSFetchRequest<AppSettings>(entityName: "AppSettings")
    }
}
