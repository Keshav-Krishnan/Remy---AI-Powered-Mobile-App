//
//  FirebaseService.swift
//  Remy
//
//  Created on 10/17/25.
//

import Foundation
// import FirebaseFirestore
// import FirebaseStorage

/// Service handling all Firebase Firestore and Storage operations
class FirebaseService {
    // MARK: - Singleton

    static let shared = FirebaseService()

    // MARK: - Private Properties

    // private let db: Firestore
    // private let storage: Storage

    // MARK: - Initialization

    private init() {
        // TODO: Uncomment when Firebase package is added
        // self.db = Firestore.firestore()
        // self.storage = Storage.storage()
    }

    // MARK: - Journal Entry Operations

    /// Create a new journal entry in Firestore
    func createEntry(_ entry: JournalEntry) async throws -> JournalEntry {
        // TODO: Implement Firebase Firestore creation
        /*
        let docRef = db.collection("journal_entries").document(entry.id.uuidString)

        let data: [String: Any] = [
            "id": entry.id.uuidString,
            "content": entry.content,
            "journalType": entry.journalType.rawValue,
            "moodTag": entry.moodTag?.rawValue ?? NSNull(),
            "themeTag": entry.themeTag?.rawValue ?? NSNull(),
            "imageUri": entry.imageUri ?? NSNull(),
            "audioUri": entry.audioUri ?? NSNull(),
            "location": entry.location ?? NSNull(),
            "aiReflection": encodeAIReflection(entry.aiReflection),
            "timestamp": Timestamp(date: entry.timestamp),
            "createdAt": Timestamp(date: Date())
        ]

        try await docRef.setData(data)
        return entry
        */

        // Mock implementation
        print("[FirebaseService] Mock: Creating entry \(entry.id)")
        return entry
    }

    /// Fetch all journal entries from Firestore
    func fetchEntries() async throws -> [JournalEntry] {
        // TODO: Implement Firebase Firestore fetch
        /*
        let snapshot = try await db.collection("journal_entries")
            .order(by: "timestamp", descending: true)
            .getDocuments()

        let entries = try snapshot.documents.compactMap { doc -> JournalEntry? in
            try decodeJournalEntry(from: doc.data())
        }

        return entries
        */

        // Mock implementation
        print("[FirebaseService] Mock: Fetching entries")
        return []
    }

    /// Fetch entries of a specific journal type
    func fetchEntries(ofType type: JournalType) async throws -> [JournalEntry] {
        // TODO: Implement Firebase Firestore filtered fetch
        /*
        let snapshot = try await db.collection("journal_entries")
            .whereField("journalType", isEqualTo: type.rawValue)
            .order(by: "timestamp", descending: true)
            .getDocuments()

        let entries = try snapshot.documents.compactMap { doc -> JournalEntry? in
            try decodeJournalEntry(from: doc.data())
        }

        return entries
        */

        // Mock implementation
        print("[FirebaseService] Mock: Fetching entries of type \(type.rawValue)")
        return []
    }

    /// Update an existing journal entry
    func updateEntry(_ entry: JournalEntry) async throws {
        // TODO: Implement Firebase Firestore update
        /*
        let docRef = db.collection("journal_entries").document(entry.id.uuidString)

        let data: [String: Any] = [
            "content": entry.content,
            "moodTag": entry.moodTag?.rawValue ?? NSNull(),
            "themeTag": entry.themeTag?.rawValue ?? NSNull(),
            "aiReflection": encodeAIReflection(entry.aiReflection)
        ]

        try await docRef.updateData(data)
        */

        // Mock implementation
        print("[FirebaseService] Mock: Updating entry \(entry.id)")
    }

    /// Delete a journal entry
    func deleteEntry(id: UUID) async throws {
        // TODO: Implement Firebase Firestore deletion
        /*
        let docRef = db.collection("journal_entries").document(id.uuidString)
        try await docRef.delete()
        */

        // Mock implementation
        print("[FirebaseService] Mock: Deleting entry \(id)")
    }

    // MARK: - Streak Operations

    /// Get current streak data
    func getStreak() async throws -> StreakData {
        // TODO: Implement Firebase Firestore streak fetch
        /*
        let docRef = db.collection("streaks").document("user_streak")
        let snapshot = try await docRef.getDocument()

        guard let data = snapshot.data() else {
            // Return default streak if none exists
            return StreakData(currentStreak: 0, longestStreak: 0, lastEntryDate: nil)
        }

        return try decodeStreakData(from: data)
        */

        // Mock implementation
        print("[FirebaseService] Mock: Fetching streak")
        return StreakData(currentStreak: 0, longestStreak: 0, lastEntryDate: nil)
    }

    /// Update streak data
    func updateStreak(_ streak: StreakData) async throws {
        // TODO: Implement Firebase Firestore streak update
        /*
        let docRef = db.collection("streaks").document("user_streak")

        let data: [String: Any] = [
            "currentStreak": streak.currentStreak,
            "longestStreak": streak.longestStreak,
            "lastEntryDate": streak.lastEntryDate.map { Timestamp(date: $0) } ?? NSNull(),
            "updatedAt": Timestamp(date: Date())
        ]

        try await docRef.setData(data, merge: true)
        */

        // Mock implementation
        print("[FirebaseService] Mock: Updating streak to \(streak.currentStreak)")
    }

    // MARK: - Storage Operations

    /// Upload a photo to Firebase Storage
    func uploadPhoto(_ imageData: Data, entryId: UUID) async throws -> String {
        // TODO: Implement Firebase Storage upload
        /*
        let storageRef = storage.reference()
        let photoRef = storageRef.child("photos/\(entryId.uuidString).jpg")

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        _ = try await photoRef.putDataAsync(imageData, metadata: metadata)
        let downloadURL = try await photoRef.downloadURL()

        return downloadURL.absoluteString
        */

        // Mock implementation
        print("[FirebaseService] Mock: Uploading photo for entry \(entryId)")
        return "mock://photo/\(entryId.uuidString).jpg"
    }

    /// Upload audio file to Firebase Storage
    func uploadAudio(_ audioURL: URL, entryId: UUID) async throws -> String {
        // TODO: Implement Firebase Storage upload
        /*
        let storageRef = storage.reference()
        let audioRef = storageRef.child("audio/\(entryId.uuidString).m4a")

        let metadata = StorageMetadata()
        metadata.contentType = "audio/m4a"

        _ = try await audioRef.putFileAsync(from: audioURL, metadata: metadata)
        let downloadURL = try await audioRef.downloadURL()

        return downloadURL.absoluteString
        */

        // Mock implementation
        print("[FirebaseService] Mock: Uploading audio for entry \(entryId)")
        return "mock://audio/\(entryId.uuidString).m4a"
    }

    /// Delete a file from Firebase Storage
    func deleteFile(at url: String) async throws {
        // TODO: Implement Firebase Storage deletion
        /*
        let storageRef = storage.reference(forURL: url)
        try await storageRef.delete()
        */

        // Mock implementation
        print("[FirebaseService] Mock: Deleting file at \(url)")
    }

    // MARK: - Private Helper Methods

    /*
    /// Encode AIReflection to Firestore compatible format
    private func encodeAIReflection(_ reflection: AIReflection?) -> Any {
        guard let reflection = reflection else { return NSNull() }

        return [
            "summary": reflection.summary,
            "dominantEmotion": reflection.dominantEmotion,
            "followUp": reflection.followUp,
            "personalizedInsight": reflection.personalizedInsight ?? NSNull(),
            "moodTrend": reflection.moodTrend ?? NSNull(),
            "growthSuggestion": reflection.growthSuggestion ?? NSNull()
        ]
    }

    /// Decode JournalEntry from Firestore data
    private func decodeJournalEntry(from data: [String: Any]) throws -> JournalEntry {
        guard
            let idString = data["id"] as? String,
            let id = UUID(uuidString: idString),
            let content = data["content"] as? String,
            let journalTypeRaw = data["journalType"] as? String,
            let journalType = JournalType(rawValue: journalTypeRaw),
            let timestamp = (data["timestamp"] as? Timestamp)?.dateValue()
        else {
            throw FirebaseServiceError.invalidData
        }

        let moodTag = (data["moodTag"] as? String).flatMap { MoodTag(rawValue: $0) }
        let themeTag = (data["themeTag"] as? String).flatMap { ThemeTag(rawValue: $0) }
        let imageUri = data["imageUri"] as? String
        let audioUri = data["audioUri"] as? String
        let location = data["location"] as? String

        let aiReflection: AIReflection?
        if let reflectionData = data["aiReflection"] as? [String: Any] {
            aiReflection = try decodeAIReflection(from: reflectionData)
        } else {
            aiReflection = nil
        }

        return JournalEntry(
            id: id,
            content: content,
            journalType: journalType,
            moodTag: moodTag,
            themeTag: themeTag,
            imageUri: imageUri,
            location: location,
            aiReflection: aiReflection,
            timestamp: timestamp,
            audioUri: audioUri
        )
    }

    /// Decode AIReflection from Firestore data
    private func decodeAIReflection(from data: [String: Any]) throws -> AIReflection {
        guard
            let summary = data["summary"] as? String,
            let dominantEmotion = data["dominantEmotion"] as? String,
            let followUp = data["followUp"] as? String
        else {
            throw FirebaseServiceError.invalidData
        }

        return AIReflection(
            summary: summary,
            dominantEmotion: dominantEmotion,
            followUp: followUp,
            personalizedInsight: data["personalizedInsight"] as? String,
            moodTrend: data["moodTrend"] as? String,
            growthSuggestion: data["growthSuggestion"] as? String
        )
    }

    /// Decode StreakData from Firestore data
    private func decodeStreakData(from data: [String: Any]) throws -> StreakData {
        let currentStreak = data["currentStreak"] as? Int ?? 0
        let longestStreak = data["longestStreak"] as? Int ?? 0
        let lastEntryDate = (data["lastEntryDate"] as? Timestamp)?.dateValue()

        return StreakData(
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            lastEntryDate: lastEntryDate
        )
    }
    */
}

// MARK: - Error Types

enum FirebaseServiceError: LocalizedError {
    case invalidData
    case uploadFailed
    case downloadFailed

    var errorDescription: String? {
        switch self {
        case .invalidData:
            return "Invalid data format from Firebase"
        case .uploadFailed:
            return "Failed to upload to Firebase Storage"
        case .downloadFailed:
            return "Failed to download from Firebase Storage"
        }
    }
}
