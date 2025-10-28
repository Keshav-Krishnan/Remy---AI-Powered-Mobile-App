//
//  AIReflection.swift
//  Remy
//
//  Created by Keshav krishnan on 10/17/25.
//

import Foundation

struct AIReflection: Codable, Identifiable {
    let id: UUID
    let summary: String
    let dominantEmotion: String
    let followUp: String
    var personalizedInsight: String?
    var moodTrend: String?
    var growthSuggestion: String?

    init(
        id: UUID = UUID(),
        summary: String,
        dominantEmotion: String,
        followUp: String,
        personalizedInsight: String? = nil,
        moodTrend: String? = nil,
        growthSuggestion: String? = nil
    ) {
        self.id = id
        self.summary = summary
        self.dominantEmotion = dominantEmotion
        self.followUp = followUp
        self.personalizedInsight = personalizedInsight
        self.moodTrend = moodTrend
        self.growthSuggestion = growthSuggestion
    }
}
