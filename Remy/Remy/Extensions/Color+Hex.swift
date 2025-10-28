//
//  Color+Hex.swift
//  Remy
//
//  Created by Keshav krishnan on 10/17/25.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    // Remy Brand Colors - Modern Aesthetic Palette
    static let remyBrown = Color(hex: "4A2C1A") // Darker brown
    static let remyCream = Color(hex: "FDF8F6")
    static let remyBeige = Color(hex: "E8DCD1")
    static let remyDarkBrown = Color(hex: "3D1F0F") // Even darker brown

    // Extended Modern Palette
    static let remyLightBrown = Color(hex: "C4A68A")
    static let remyWarmWhite = Color(hex: "FFFCF9")
    static let remyCardBg = Color(hex: "FFFFFF")
    static let remySoftGray = Color(hex: "F5F5F5")
    static let remyTextPrimary = Color(hex: "2C2C2C")
    static let remyTextSecondary = Color(hex: "8E8E93")

    // Accent Colors
    static let remyOrange = Color(hex: "FF6B35")
    static let remyPeach = Color(hex: "FFB8A3")
    static let remyGreen = Color(hex: "6BCF7F")
    static let remyPurple = Color(hex: "9B87F5")
    static let remyBlue = Color(hex: "74B9FF")
}
