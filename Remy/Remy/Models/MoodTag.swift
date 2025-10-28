//
//  MoodTag.swift
//  Remy
//
//  Created by Keshav krishnan on 10/17/25.
//

import Foundation
import SwiftUI

enum MoodTag: String, Codable, CaseIterable, Identifiable {
    case happy
    case grateful
    case excited
    case neutral
    case sad
    case anxious
    case stressed
    case angry

    var id: String { rawValue }

    var displayName: String {
        rawValue.capitalized
    }

    var color: Color {
        switch self {
        case .happy: return Color(hex: "FFD93D")
        case .grateful: return Color(hex: "6BCF7F")
        case .excited: return Color(hex: "FF6B6B")
        case .neutral: return Color(hex: "A8A8A8")
        case .sad: return Color(hex: "74B9FF")
        case .anxious: return Color(hex: "FDCB6E")
        case .stressed: return Color(hex: "E17055")
        case .angry: return Color(hex: "D63031")
        }
    }

    var score: Int {
        switch self {
        case .happy: return 5
        case .excited: return 4
        case .grateful: return 4
        case .neutral: return 3
        case .anxious: return 2
        case .stressed: return 2
        case .sad: return 1
        case .angry: return 1
        }
    }

    var icon: String {
        switch self {
        case .happy: return "😊"
        case .grateful: return "🙏"
        case .excited: return "🎉"
        case .neutral: return "😐"
        case .sad: return "😢"
        case .anxious: return "😰"
        case .stressed: return "😓"
        case .angry: return "😠"
        }
    }
}
