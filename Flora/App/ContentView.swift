//
//  ContentView.swift
//  Flora
//
//  Created by Tejas Marimuthu on 2025.10.28.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var repository: DataRepository
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "house.fill")
                }
                .tag(0)
            
            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
                .tag(1)
            
            InsightsView()
                .tabItem {
                    Label("Insights", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(2)
            
            RemindersView()
                .tabItem {
                    Label("Reminders", systemImage: "bell.fill")
                }
                .tag(3)
            
            MoreView()
                .tabItem {
                    Label("More", systemImage: "ellipsis.circle.fill")
                }
                .tag(4)
        }
        .accentColor(FloraColor.rose)
    }
}
