//
//  FloraTheme.swift
//  Flora
//
//  Created by Tejas Marimuthu on 2025.11.04.
//

import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// MARK: - Colors
enum FloraColor {
    // Base neutrals
    static let porcelain = Color(hex: "F8F8F8")
    static let ink = Color(hex: "0B0B0C")
    static let mist = Color(hex: "EDEDEF")
    
    // Accent colors
    static let rose = Color(hex: "FF7A8A")
    static let coral = Color(hex: "FF8E72")
    static let lavender = Color(hex: "A08CFF")
    static let sage = Color(hex: "A6C1A8")
    
    // Semantic colors
    static let background: Color = {
#if os(iOS)
        Color(UIColor.systemBackground)
#elseif os(macOS)
        Color(nsColor: NSColor.windowBackgroundColor)
#endif
    }()
    
    static let secondaryBackground: Color = {
#if os(iOS)
        Color(UIColor.secondarySystemBackground)
#elseif os(macOS)
        Color(nsColor: NSColor.underPageBackgroundColor)
#endif
    }()
    
    static let tertiaryBackground: Color = {
#if os(iOS)
        Color(UIColor.tertiarySystemBackground)
#elseif os(macOS)
        Color(nsColor: NSColor.controlBackgroundColor)
#endif
    }()
    
    static let label: Color = {
#if os(iOS)
        Color(UIColor.label)
#elseif os(macOS)
        Color(nsColor: NSColor.labelColor)
#endif
    }()
    
    static let secondaryLabel: Color = {
#if os(iOS)
        Color(UIColor.secondaryLabel)
#elseif os(macOS)
        Color(nsColor: NSColor.secondaryLabelColor)
#endif
    }()
    
    static let tertiaryLabel: Color = {
#if os(iOS)
        Color(UIColor.tertiaryLabel)
#elseif os(macOS)
        Color(nsColor: NSColor.tertiaryLabelColor)
#endif
    }()
    
    // Flow levels
    static let spotting = Color.gray.opacity(0.3)
    static let lightFlow = rose.opacity(0.4)
    static let mediumFlow = rose.opacity(0.7)
    static let heavyFlow = rose
    
    // Phase colors
    static let menstruation = rose
    static let follicular = coral.opacity(0.6)
    static let ovulation = lavender
    static let luteal = sage
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6: // RGB
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255
        )
    }
}

// MARK: - Typography
enum FloraFont {
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title1 = Font.system(size: 28, weight: .bold, design: .rounded)
    static let title2 = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let headline = Font.system(size: 17, weight: .semibold, design: .default)
    static let body = Font.system(size: 17, weight: .regular, design: .default)
    static let callout = Font.system(size: 16, weight: .regular, design: .default)
    static let subheadline = Font.system(size: 15, weight: .regular, design: .default)
    static let footnote = Font.system(size: 13, weight: .regular, design: .default)
    static let caption = Font.system(size: 12, weight: .regular, design: .default)
    static let caption2 = Font.system(size: 11, weight: .regular, design: .default)
}

// MARK: - Spacing
enum FloraSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - Corner Radius
enum FloraRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
}

// MARK: - Components

// MARK: FloraCard
struct FloraCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .background(FloraColor.background)
        .cornerRadius(FloraRadius.md)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: FloraButton
enum FloraButtonStyle {
    case primary
    case secondary
    case tertiary
}

struct FloraButton: View {
    let title: String
    let style: FloraButtonStyle
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(FloraFont.headline)
                .foregroundColor(foregroundColor)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(backgroundColor)
                .cornerRadius(FloraRadius.md)
        }
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary:
            return FloraColor.rose
        case .secondary:
            return FloraColor.mist
        case .tertiary:
            return Color.clear
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary:
            return .white
        case .secondary:
            return FloraColor.ink
        case .tertiary:
            return FloraColor.rose
        }
    }
}

// MARK: FlowLevelPicker
struct FlowLevelPicker: View {
    @Binding var selectedLevel: Int
    
    let levels = [
        (0, "Spotting", FloraColor.spotting),
        (1, "Light", FloraColor.lightFlow),
        (2, "Medium", FloraColor.mediumFlow),
        (3, "Heavy", FloraColor.heavyFlow)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: FloraSpacing.sm) {
            Text("Flow Level")
                .font(FloraFont.subheadline)
                .foregroundColor(FloraColor.secondaryLabel)
            
            HStack(spacing: FloraSpacing.sm) {
                ForEach(levels, id: \.0) { level, label, color in
                    Button(action: {
                        selectedLevel = level
                    }) {
                        VStack(spacing: FloraSpacing.xs) {
                            Circle()
                                .fill(color)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Circle()
                                        .strokeBorder(
                                            selectedLevel == level ? FloraColor.rose : Color.clear,
                                            lineWidth: 3
                                        )
                                )
                            
                            Text(label)
                                .font(FloraFont.caption)
                                .foregroundColor(
                                    selectedLevel == level ? FloraColor.label : FloraColor.secondaryLabel
                                )
                        }
                    }
                }
            }
        }
    }
}

// MARK: IntensityPicker
struct IntensityPicker: View {
    let title: String
    @Binding var intensity: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: FloraSpacing.sm) {
            Text(title)
                .font(FloraFont.subheadline)
                .foregroundColor(FloraColor.secondaryLabel)
            
            HStack(spacing: FloraSpacing.xs) {
                ForEach(0...3, id: \.self) { level in
                    Button(action: {
                        intensity = level
                    }) {
                        Circle()
                            .fill(intensity >= level ? FloraColor.rose : FloraColor.mist)
                            .frame(width: 44, height: 44)
                            .overlay(
                                Text("\(level)")
                                    .font(FloraFont.callout)
                                    .foregroundColor(
                                        intensity >= level ? .white : FloraColor.secondaryLabel
                                    )
                            )
                    }
                }
            }
        }
    }
}

// MARK: CyclePhaseChip
struct CyclePhaseChip: View {
    let phase: CyclePhase
    
    var body: some View {
        HStack(spacing: FloraSpacing.xs) {
            Circle()
                .fill(phase.color)
                .frame(width: 8, height: 8)
            
            Text(phase.rawValue)
                .font(FloraFont.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, FloraSpacing.sm)
        .padding(.vertical, FloraSpacing.xs)
        .background(phase.color.opacity(0.15))
        .cornerRadius(FloraRadius.sm)
    }
}

enum CyclePhase: String {
    case menstruation = "Menstruation"
    case follicular = "Follicular"
    case ovulation = "Ovulation"
    case luteal = "Luteal"
    
    var color: Color {
        switch self {
        case .menstruation: return FloraColor.menstruation
        case .follicular: return FloraColor.follicular
        case .ovulation: return FloraColor.ovulation
        case .luteal: return FloraColor.luteal
        }
    }
    
    static func from(cycleDay: Int, cycleLength: Int) -> CyclePhase {
        if cycleDay <= 5 {
            return .menstruation
        } else if cycleDay <= cycleLength / 2 - 2 {
            return .follicular
        } else if cycleDay <= cycleLength / 2 + 2 {
            return .ovulation
        } else {
            return .luteal
        }
    }
}

// MARK: - Preview Helpers
struct FloraCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: FloraSpacing.md) {
            FloraCard {
                VStack(alignment: .leading, spacing: FloraSpacing.sm) {
                    Text("Next Period")
                        .font(FloraFont.headline)
                    
                    Text("Nov 18–20")
                        .font(FloraFont.title2)
                        .foregroundColor(FloraColor.rose)
                    
                    Text("Based on your last 6 cycles")
                        .font(FloraFont.caption)
                        .foregroundColor(FloraColor.secondaryLabel)
                }
                .padding(FloraSpacing.md)
            }
            
            CyclePhaseChip(phase: .follicular)
            
            FlowLevelPicker(selectedLevel: .constant(2))
                .padding()
        }
        .padding()
        .background(FloraColor.porcelain)
    }
}
