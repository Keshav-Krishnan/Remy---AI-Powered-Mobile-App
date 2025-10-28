//
//  ThemeTag.swift
//  Remy
//
//  Created by Keshav krishnan on 10/17/25.
//

import Foundation
import SwiftUI

enum ThemeTag: String, Codable, CaseIterable, Identifiable {
    case personal
    case work
    case relationships
    case family
    case health
    case goals
    case hobbies
    case school

    var id: String { rawValue }

    var displayName: String {
        rawValue.capitalized
    }

    var color: Color {
        switch self {
        case .personal: return Color(hex: "6C5CE7")
        case .work: return Color(hex: "00B894")
        case .relationships: return Color(hex: "FD79A8")
        case .family: return Color(hex: "FAB1A0")
        case .health: return Color(hex: "00CEC9")
        case .goals: return Color(hex: "FF7675")
        case .hobbies: return Color(hex: "A29BFE")
        case .school: return Color(hex: "55A3FF")
        }
    }

    var icon: String {
        switch self {
        case .personal: return "person.fill"
        case .work: return "briefcase.fill"
        case .relationships: return "heart.fill"
        case .family: return "house.fill"
        case .health: return "heart.text.square.fill"
        case .goals: return "target"
        case .hobbies: return "paintbrush.fill"
        case .school: return "book.fill"
        }
    }
}
