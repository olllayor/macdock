import SwiftUI

enum MacDockColors {
    static let background = Color(hex: 0x0F172A)
    static let foreground = Color(hex: 0xE2E8F0)
    static let card = Color(hex: 0x1E293B)
    static let primary = Color(hex: 0x3B82F6)
    static let primaryForeground = Color(hex: 0x0F172A)
    static let secondary = Color(hex: 0x334155)
    static let muted = Color(hex: 0x475569)
    static let mutedForeground = Color(hex: 0xCBD5E1)
    static let accent = Color(hex: 0x0EA5E9)
    static let accentForeground = Color(hex: 0x0F172A)
    static let destructive = Color(hex: 0xEF4444)
    static let border = Color(hex: 0x334155)
    static let input = Color(hex: 0x1E293B)
    static let sidebar = Color(hex: 0x1E293B)
    static let sidebarForeground = Color(hex: 0xE2E8F0)
    static let sidebarPrimary = Color(hex: 0x3B82F6)
    static let sidebarPrimaryForeground = Color(hex: 0x0F172A)
    static let sidebarBorder = Color(hex: 0x334155)
    static let chartBlue = Color(hex: 0x3B82F6)
    static let chartCyan = Color(hex: 0x0EA5E9)
    static let chartGreen = Color(hex: 0x10B981)
    static let chartPurple = Color(hex: 0x8B5CF6)
}

extension Color {
    init(hex: UInt, opacity: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: opacity
        )
    }
}
