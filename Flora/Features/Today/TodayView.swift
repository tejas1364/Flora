//
//  TodayView.swift
//  Flora
//
//  Created by Tejas Marimuthu on 2025.11.04.
//

// MARK: - TodayView.swift
// Main dashboard

import SwiftUI

struct TodayView: View {
    @EnvironmentObject var repository: DataRepository
    @StateObject private var viewModel = TodayViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: FloraSpacing.lg) {
                    // Cycle Status Header
                    statusHeader
                    
                    // Next Period Prediction
                    if let prediction = viewModel.prediction {
                        predictionCard(prediction)
                    }
                    
                    // Quick Log Actions
                    quickLogSection
                }
                .padding(FloraSpacing.md)
            }
            .navigationTitle("Today")
            .background(FloraColor.porcelain.ignoresSafeArea())
        }
        .onAppear {
            viewModel.loadData(repository: repository)
        }
    }
    
    private var statusHeader: some View {
        VStack(spacing: FloraSpacing.sm) {
            if let cycleDay = viewModel.currentCycleDay {
                Text("Cycle Day \(cycleDay)")
                    .font(FloraFont.title1)
                    .foregroundColor(FloraColor.label)
                
                CyclePhaseChip(phase: viewModel.currentPhase)
            } else {
                Text("Ready to Start Tracking")
                    .font(FloraFont.title2)
                    .foregroundColor(FloraColor.label)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, FloraSpacing.lg)
    }
    
    private func predictionCard(_ prediction: CyclePrediction) -> some View {
        FloraCard {
            VStack(alignment: .leading, spacing: FloraSpacing.sm) {
                HStack {
                    Text("Next Period")
                        .font(FloraFont.headline)
                        .foregroundColor(FloraColor.label)
                    
                    Spacer()
                    
                    Image(systemName: "drop.fill")
                        .foregroundColor(FloraColor.rose)
                }
                
                Text(formatDateRange(
                    start: prediction.confidenceBandMin,
                    end: prediction.confidenceBandMax
                ))
                .font(FloraFont.title2)
                .foregroundColor(FloraColor.rose)
                
                // Confidence indicator
                HStack(spacing: FloraSpacing.xs) {
                    ForEach(0..<5) { index in
                        Circle()
                            .fill(
                                Double(index) < prediction.confidence * 5
                                    ? FloraColor.rose
                                    : FloraColor.mist
                            )
                            .frame(width: 6, height: 6)
                    }
                    
                    Text("\(Int(prediction.confidence * 100))% confidence")
                        .font(FloraFont.caption)
                        .foregroundColor(FloraColor.secondaryLabel)
                }
                
                Text(prediction.rationale)
                    .font(FloraFont.caption)
                    .foregroundColor(FloraColor.secondaryLabel)
                    .padding(.top, FloraSpacing.xs)
            }
            .padding(FloraSpacing.md)
        }
    }
    
    private var quickLogSection: some View {
        VStack(spacing: FloraSpacing.md) {
            Text("Quick Log")
                .font(FloraFont.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: FloraSpacing.sm) {
                QuickLogButton(
                    icon: "drop.fill",
                    title: "Period",
                    color: FloraColor.rose
                ) {
                    viewModel.showPeriodLog = true
                }
                
                QuickLogButton(
                    icon: "heart.fill",
                    title: "Symptom",
                    color: FloraColor.coral
                ) {
                    viewModel.showSymptomLog = true
                }
                
                QuickLogButton(
                    icon: "thermometer",
                    title: "BBT",
                    color: FloraColor.lavender
                ) {
                    viewModel.showBBTLog = true
                }
            }
        }
        .sheet(isPresented: $viewModel.showPeriodLog) {
            PeriodLogSheet()
        }
        .sheet(isPresented: $viewModel.showSymptomLog) {
            SymptomLogSheet()
        }
        .sheet(isPresented: $viewModel.showBBTLog) {
            BBTLogSheet()
        }
    }
    
    private func formatDateRange(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        
        if Calendar.current.isDate(start, equalTo: end, toGranularity: .day) {
            return formatter.string(from: start)
        } else {
            return "\(formatter.string(from: start))–\(formatter.string(from: end))"
        }
    }
}

// MARK: - TodayViewModel
class TodayViewModel: ObservableObject {
    @Published var currentCycleDay: Int?
    @Published var currentPhase: CyclePhase = .follicular
    @Published var prediction: CyclePrediction?
    
    @Published var showPeriodLog = false
    @Published var showSymptomLog = false
    @Published var showBBTLog = false
    
    func loadData(repository: DataRepository) {
        if let cycle = repository.getCurrentCycle() {
            let components = Calendar.current.dateComponents(
                [.day],
                from: cycle.startDate,
                to: Date()
            )
            currentCycleDay = (components.day ?? 0) + 1
            
            // Generate prediction
            let engine = PredictionEngine(repository: repository)
            prediction = engine.generatePrediction()
            
            // Determine current phase
            if let cycleDay = currentCycleDay, let pred = prediction {
                let cycleLength = Calendar.current.dateComponents(
                    [.day],
                    from: cycle.startDate,
                    to: pred.nextPeriodStart
                ).day ?? 28
                
                currentPhase = CyclePhase.from(cycleDay: cycleDay, cycleLength: cycleLength)
            }
        }
    }
}

// MARK: - QuickLogButton
struct QuickLogButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: FloraSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                    .frame(width: 50, height: 50)
                    .background(color.opacity(0.15))
                    .clipShape(Circle())
                
                Text(title)
                    .font(FloraFont.caption)
                    .foregroundColor(FloraColor.label)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Placeholder Views
struct CalendarView: View {
    var body: some View {
        NavigationView {
            Text("Calendar View")
                .navigationTitle("Calendar")
        }
    }
}

struct InsightsView: View {
    var body: some View {
        NavigationView {
            Text("Insights View")
                .navigationTitle("Insights")
        }
    }
}

struct RemindersView: View {
    var body: some View {
        NavigationView {
            Text("Reminders View")
                .navigationTitle("Reminders")
        }
    }
}

struct MoreView: View {
    var body: some View {
        NavigationView {
            List {
                Section("Modes") {
                    NavigationLink("Standard Mode", destination: Text("Standard"))
                    NavigationLink("TTC Mode", destination: Text("TTC"))
                }
                
                Section("Data") {
                    NavigationLink("Export Data", destination: Text("Export"))
                    NavigationLink("Import Data", destination: Text("Import"))
                }
                
                Section("Privacy & Security") {
                    NavigationLink("App Lock", destination: Text("App Lock"))
                    NavigationLink("Health Access", destination: Text("Health"))
                }
                
                Section("About") {
                    NavigationLink("Privacy Policy", destination: Text("Privacy"))
                    NavigationLink("Help & Support", destination: Text("Help"))
                }
            }
            .navigationTitle("More")
        }
    }
}

// MARK: - Log Sheets (Placeholders)
struct PeriodLogSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var repository: DataRepository
    @State private var flowLevel = 2
    @State private var date = Date()
    
    var body: some View {
        NavigationView {
            Form {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                
                FlowLevelPicker(selectedLevel: $flowLevel)
                    .padding(.vertical)
            }
            .navigationTitle("Log Period")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        repository.logPeriodEvent(
                            date: date,
                            flowLevel: flowLevel,
                            isSpotting: flowLevel == 0
                        )
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

struct SymptomLogSheet: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Text("Symptom Log")
                .navigationTitle("Log Symptom")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
        }
    }
}

struct BBTLogSheet: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Text("BBT Log")
                .navigationTitle("Log Temperature")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
        }
    }
}

// MARK: - Previews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(DataRepository(persistenceController: .preview))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
