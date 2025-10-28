//
//  JournalEntry.swift
//  Remy
//
//  Created by Keshav krishnan on 10/17/25.
//

import Foundation

struct JournalEntry: Codable, Identifiable {
    let id: UUID
    var content: String
    let journalType: JournalType
    var moodTag: MoodTag?
    var themeTag: ThemeTag?
    var imageUri: String?
    var audioUri: String?
    var location: String?
    var aiReflection: AIReflection?
    let timestamp: Date
    var createdAt: Date

    init(
        id: UUID = UUID(),
        content: String,
        journalType: JournalType,
        moodTag: MoodTag? = nil,
        themeTag: ThemeTag? = nil,
        imageUri: String? = nil,
        audioUri: String? = nil,
        location: String? = nil,
        aiReflection: AIReflection? = nil,
        timestamp: Date = Date(),
        createdAt: Date = Date()
    ) {
        self.id = id
        self.content = content
        self.journalType = journalType
        self.moodTag = moodTag
        self.themeTag = themeTag
        self.imageUri = imageUri
        self.audioUri = audioUri
        self.location = location
        self.aiReflection = aiReflection
        self.timestamp = timestamp
        self.createdAt = createdAt
    }
}
