//
//  JournalType.swift
//  Remy
//
//  Created by Keshav krishnan on 10/17/25.
//

import Foundation

enum JournalType: String, Codable, CaseIterable, Identifiable {
    case quick
    case personal
    case photo
    case gratitude
    case goals
    case reflection
    case dreams
    case travel

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .quick: return "Quick Entry"
        case .personal: return "Personal Reflection"
        case .photo: return "Photo Journal"
        case .gratitude: return "Gratitude"
        case .goals: return "Goals"
        case .reflection: return "Reflection"
        case .dreams: return "Dream Journal"
        case .travel: return "Travel Journal"
        }
    }

    var icon: String {
        switch self {
        case .quick: return "bolt.fill"
        case .personal: return "person.fill"
        case .photo: return "camera.fill"
        case .gratitude: return "heart.fill"
        case .goals: return "target"
        case .reflection: return "brain.head.profile"
        case .dreams: return "moon.stars.fill"
        case .travel: return "airplane"
        }
    }
}
