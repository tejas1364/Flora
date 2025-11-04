//
//  MARK: - PredictionEngine.swift
//  Flora
//
//  Created by Tejas Marimuthu on 2025.11.04.
//

// On-device cycle prediction algorithms

import Foundation

struct CyclePrediction {
    let nextPeriodStart: Date
    let nextPeriodEnd: Date
    let confidenceBandMin: Date
    let confidenceBandMax: Date
    let confidence: Double  // 0.0 to 1.0
    let currentCycleDay: Int
    let isIrregular: Bool
    let rationale: String
    
    // Fertile window (optional, depends on mode)
    let fertileWindowStart: Date?
    let fertileWindowEnd: Date?
    let ovulationEstimate: Date?
}

class PredictionEngine {
    private let repository: DataRepository
    
    // Configuration
    private let minCyclesForPrediction = 3
    private let maxCyclesForStats = 6
    private let defaultLutealLength = 14
    private let minPhysiologicalCycle = 21
    private let maxPhysiologicalCycle = 38
    
    init(repository: DataRepository) {
        self.repository = repository
    }
    
    // MARK: - Main Prediction Method
    func generatePrediction() -> CyclePrediction? {
        guard let currentCycle = repository.getCurrentCycle() else {
            return nil
        }
        
        let historicalCycles = repository.getAllCycles(limit: maxCyclesForStats + 1)
        
        // Need at least minCycles of completed cycles
        let completedCycles = historicalCycles.filter { $0.endDate != nil }
        guard completedCycles.count >= minCyclesForPrediction else {
            return generateFirstCyclePrediction(currentCycle: currentCycle)
        }
        
        // Calculate statistics
        let cycleLengths = completedCycles.prefix(maxCyclesForStats).map {
            calculateCycleLength(cycle: $0)
        }
        
        let stats = calculateCycleStats(cycleLengths: cycleLengths)
        let currentCycleDay = calculateCycleDay(cycle: currentCycle)
        
        // Check for irregularity
        let isIrregular = checkIrregularity(cycleLengths: cycleLengths, stats: stats)
        
        // Generate prediction
        let avgCycleLength = stats.mean
        let stdDev = stats.standardDeviation
        
        let nextPeriodStart = Calendar.current.date(
            byAdding: .day,
            value: Int(avgCycleLength),
            to: currentCycle.startDate
        )!
        
        // Confidence band: ±1σ
        let minDays = max(minPhysiologicalCycle, Int(avgCycleLength - stdDev))
        let maxDays = min(maxPhysiologicalCycle, Int(avgCycleLength + stdDev))
        
        let confidenceBandMin = Calendar.current.date(
            byAdding: .day,
            value: minDays,
            to: currentCycle.startDate
        )!
        
        let confidenceBandMax = Calendar.current.date(
            byAdding: .day,
            value: maxDays,
            to: currentCycle.startDate
        )!
        
        // Estimate period end (avg 5 days)
        let nextPeriodEnd = Calendar.current.date(
            byAdding: .day,
            value: 5,
            to: nextPeriodStart
        )!
        
        // Calculate confidence score (inverse of coefficient of variation)
        let cv = stdDev / avgCycleLength
        let confidence = max(0.0, min(1.0, 1.0 - (cv / 0.5)))  // normalize to 0-1
        
        // Generate fertile window
        let (fertileStart, fertileEnd, ovulation) = calculateFertileWindow(
            currentCycle: currentCycle,
            avgCycleLength: avgCycleLength,
            historicalCycles: completedCycles
        )
        
        let rationale = generateRationale(
            cycleCount: cycleLengths.count,
            avgLength: avgCycleLength,
            stdDev: stdDev,
            isIrregular: isIrregular
        )
        
        return CyclePrediction(
            nextPeriodStart: nextPeriodStart,
            nextPeriodEnd: nextPeriodEnd,
            confidenceBandMin: confidenceBandMin,
            confidenceBandMax: confidenceBandMax,
            confidence: confidence,
            currentCycleDay: currentCycleDay,
            isIrregular: isIrregular,
            rationale: rationale,
            fertileWindowStart: fertileStart,
            fertileWindowEnd: fertileEnd,
            ovulationEstimate: ovulation
        )
    }
    
    // MARK: - First Cycle Prediction
    private func generateFirstCyclePrediction(currentCycle: Cycle) -> CyclePrediction {
        // Use population average of 28 days
        let avgCycleLength = 28.0
        let currentCycleDay = calculateCycleDay(cycle: currentCycle)
        
        let nextPeriodStart = Calendar.current.date(
            byAdding: .day,
            value: Int(avgCycleLength),
            to: currentCycle.startDate
        )!
        
        let nextPeriodEnd = Calendar.current.date(
            byAdding: .day,
            value: 5,
            to: nextPeriodStart
        )!
        
        // Wide confidence band for first prediction
        let confidenceBandMin = Calendar.current.date(
            byAdding: .day,
            value: 24,
            to: currentCycle.startDate
        )!
        
        let confidenceBandMax = Calendar.current.date(
            byAdding: .day,
            value: 35,
            to: currentCycle.startDate
        )!
        
        // Estimate ovulation (day 14)
        let ovulation = Calendar.current.date(
            byAdding: .day,
            value: 14,
            to: currentCycle.startDate
        )!
        
        let fertileStart = Calendar.current.date(
            byAdding: .day,
            value: -5,
            to: ovulation
        )!
        
        let fertileEnd = Calendar.current.date(
            byAdding: .day,
            value: 1,
            to: ovulation
        )!
        
        return CyclePrediction(
            nextPeriodStart: nextPeriodStart,
            nextPeriodEnd: nextPeriodEnd,
            confidenceBandMin: confidenceBandMin,
            confidenceBandMax: confidenceBandMax,
            confidence: 0.5,
            currentCycleDay: currentCycleDay,
            isIrregular: false,
            rationale: "Based on typical 28-day cycle. Prediction will improve as we learn your unique patterns.",
            fertileWindowStart: fertileStart,
            fertileWindowEnd: fertileEnd,
            ovulationEstimate: ovulation
        )
    }
    
    // MARK: - Cycle Statistics
    private struct CycleStats {
        let mean: Double
        let standardDeviation: Double
        let variance: Double
        let median: Double
        let iqr: Double
    }
    
    private func calculateCycleStats(cycleLengths: [Int]) -> CycleStats {
        let lengths = cycleLengths.map { Double($0) }
        let mean = lengths.reduce(0, +) / Double(lengths.count)
        
        let variance = lengths.reduce(0) { $0 + pow($1 - mean, 2) } / Double(lengths.count)
        let stdDev = sqrt(variance)
        
        let sorted = lengths.sorted()
        let median = sorted[sorted.count / 2]
        
        let q1Index = sorted.count / 4
        let q3Index = (3 * sorted.count) / 4
        let iqr = sorted[q3Index] - sorted[q1Index]
        
        return CycleStats(
            mean: mean,
            standardDeviation: stdDev,
            variance: variance,
            median: median,
            iqr: iqr
        )
    }
    
    // MARK: - Helper Methods
    private func calculateCycleLength(cycle: Cycle) -> Int {
        guard let endDate = cycle.endDate else {
            return 0
        }
        
        let components = Calendar.current.dateComponents(
            [.day],
            from: cycle.startDate,
            to: endDate
        )
        
        return components.day ?? 0
    }
    
    private func calculateCycleDay(cycle: Cycle) -> Int {
        let components = Calendar.current.dateComponents(
            [.day],
            from: cycle.startDate,
            to: Date()
        )
        
        return (components.day ?? 0) + 1
    }
    
    private func checkIrregularity(cycleLengths: [Int], stats: CycleStats) -> Bool {
        // Check if any cycle is outside 1.5×IQR or 2σ
        let lowerBound = max(Double(minPhysiologicalCycle), stats.mean - 2 * stats.standardDeviation)
        let upperBound = min(Double(maxPhysiologicalCycle), stats.mean + 2 * stats.standardDeviation)
        
        return cycleLengths.contains { length in
            Double(length) < lowerBound || Double(length) > upperBound
        }
    }
    
    private func calculateFertileWindow(
        currentCycle: Cycle,
        avgCycleLength: Double,
        historicalCycles: [Cycle]
    ) -> (Date?, Date?, Date?) {
        // Estimate ovulation: avgCycleLength - lutealLength
        // For now, use standard 14-day luteal phase
        // TODO: Learn luteal length from BBT data
        
        let ovulationDay = Int(avgCycleLength) - defaultLutealLength
        
        guard let ovulation = Calendar.current.date(
            byAdding: .day,
            value: ovulationDay,
            to: currentCycle.startDate
        ) else {
            return (nil, nil, nil)
        }
        
        // Fertile window: 5 days before to 1 day after ovulation
        let fertileStart = Calendar.current.date(
            byAdding: .day,
            value: -5,
            to: ovulation
        )
        
        let fertileEnd = Calendar.current.date(
            byAdding: .day,
            value: 1,
            to: ovulation
        )
        
        return (fertileStart, fertileEnd, ovulation)
    }
    
    private func generateRationale(
        cycleCount: Int,
        avgLength: Double,
        stdDev: Double,
        isIrregular: Bool
    ) -> String {
        var parts: [String] = []
        
        parts.append("Based on your last \(cycleCount) cycles")
        parts.append("average length is \(Int(avgLength)) days")
        
        if isIrregular {
            parts.append("Your cycles show some variation, so we've widened the prediction window")
        }
        
        if stdDev < 2 {
            parts.append("Your cycles are very regular")
        } else if stdDev > 5 {
            parts.append("Your cycles vary more than typical")
        }
        
        return parts.joined(separator: ". ") + "."
    }
}
