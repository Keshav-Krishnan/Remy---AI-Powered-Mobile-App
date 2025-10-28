//
//  StreakData.swift
//  Remy
//
//  Created by Keshav krishnan on 10/17/25.
//

import Foundation

struct StreakData: Codable {
    var currentStreak: Int
    var longestStreak: Int
    var lastEntryDate: Date?

    init(
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        lastEntryDate: Date? = nil
    ) {
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.lastEntryDate = lastEntryDate
    }
}
