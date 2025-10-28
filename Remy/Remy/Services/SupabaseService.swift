//
//  SupabaseService.swift
//  Remy
//
//  Created by Claude Code on 10/18/25.
//

import Foundation
import Supabase

@MainActor
class SupabaseService: ObservableObject {
    static let shared = SupabaseService()

    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var initializationError: String?
    @Published var isInitializing = true

    private let client: SupabaseClient

    private init() {
        let urlString = SupabaseConfig.projectURL
        let url = URL(string: urlString) ?? URL(string: "https://placeholder.supabase.co")!

        self.client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: SupabaseConfig.anonKey
        )
        if urlString.contains("placeholder") {
            self.initializationError = "Supabase configuration is incomplete. Please check your Config.xcconfig file."
            print("[SupabaseService] ERROR: Running with placeholder configuration")
            self.isInitializing = false
            return
        }

        Task {
            // skip auth check if no session stored
            let hasStoredSession = UserDefaults.standard.bool(forKey: "hasSupabaseSession")

            if hasStoredSession {
                await withTaskTimeout(seconds: 2.0) {
                    await self.checkAuthStatus()
                }
            } else {
                await MainActor.run {
                    self.isAuthenticated = false
                    self.currentUser = nil
                }
            }

            await MainActor.run {
                self.isInitializing = false
            }
        }
    }
    func checkAuthStatus() async {
        do {
            let session = try await client.auth.session
            await MainActor.run {
                self.currentUser = session.user
                self.isAuthenticated = true
            }
        } catch {
            await MainActor.run {
                self.currentUser = nil
                self.isAuthenticated = false
            }
        }
    }
    func signUp(email: String, password: String) async throws -> User {
        let response = try await client.auth.signUp(email: email, password: password)
        let user = response.user
        try await createUserProfile(userId: user.id, email: email)

        self.currentUser = user
        self.isAuthenticated = true
        UserDefaults.standard.set(true, forKey: "hasSupabaseSession")

        return user
    }
    func signIn(email: String, password: String) async throws -> User {
        let session = try await client.auth.signIn(email: email, password: password)

        self.currentUser = session.user
        self.isAuthenticated = true
        UserDefaults.standard.set(true, forKey: "hasSupabaseSession")

        return session.user
    }
    func signOut() async throws {
        try await client.auth.signOut()
        self.currentUser = nil
        self.isAuthenticated = false
        UserDefaults.standard.set(false, forKey: "hasSupabaseSession")
    }
    func deleteAccount() async throws {
        guard let userId = currentUser?.id else {
            throw SupabaseServiceError.notAuthenticated
        }
        try await client
            .from("journal_entries")
            .delete()
            .eq("user_id", value: userId.uuidString)
            .execute()
        try await client
            .from("streak_data")
            .delete()
            .eq("user_id", value: userId.uuidString)
            .execute()
        try await client
            .from("chat_messages")
            .delete()
            .eq("user_id", value: userId.uuidString)
            .execute()
        try await client
            .from("profiles")
            .delete()
            .eq("id", value: userId.uuidString)
            .execute()

        // just sign out for now since supabase doesnt let us delete auth user from client
        try await signOut()
    }
    func resetPassword(email: String) async throws {
        try await client.auth.resetPasswordForEmail(email)
    }
    private func createUserProfile(userId: UUID, email: String) async throws {
        struct ProfileInsert: Encodable {
            let id: String
            let email: String
            let created_at: String
            let updated_at: String
        }

        let profile = ProfileInsert(
            id: userId.uuidString,
            email: email,
            created_at: ISO8601DateFormatter().string(from: Date()),
            updated_at: ISO8601DateFormatter().string(from: Date())
        )

        try await client
            .from("profiles")
            .insert(profile)
            .execute()
    }
    fileprivate func getUserProfile() async throws -> UserProfile? {
        guard let userId = currentUser?.id else {
            throw SupabaseServiceError.notAuthenticated
        }

        let response: [UserProfile] = try await client
            .from("profiles")
            .select()
            .eq("id", value: userId.uuidString)
            .execute()
            .value

        return response.first
    }
    func updateUserProfile(fullName: String?, avatarUrl: String?) async throws {
        guard let userId = currentUser?.id else {
            throw SupabaseServiceError.notAuthenticated
        }

        struct ProfileUpdate: Encodable {
            let full_name: String?
            let avatar_url: String?
            let updated_at: String
        }

        let updates = ProfileUpdate(
            full_name: fullName,
            avatar_url: avatarUrl,
            updated_at: ISO8601DateFormatter().string(from: Date())
        )

        try await client
            .from("profiles")
            .update(updates)
            .eq("id", value: userId.uuidString)
            .execute()
    }
    func createJournalEntry(_ entry: JournalEntry) async throws -> JournalEntry {
        guard let userId = currentUser?.id else {
            throw SupabaseServiceError.notAuthenticated
        }

        let entryData = convertJournalEntryToDatabase(entry, userId: userId)

        try await client
            .from("journal_entries")
            .insert(entryData)
            .execute()
        try await updateStreak()

        return entry
    }
    func fetchJournalEntries() async throws -> [JournalEntry] {
        guard let userId = currentUser?.id else {
            throw SupabaseServiceError.notAuthenticated
        }

        let response: [JournalEntryDB] = try await client
            .from("journal_entries")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("timestamp", ascending: false)
            .execute()
            .value

        return response.compactMap { convertDatabaseToJournalEntry($0) }
    }
    func updateJournalEntry(_ entry: JournalEntry) async throws {
        guard let userId = currentUser?.id else {
            throw SupabaseServiceError.notAuthenticated
        }

        let entryData = convertJournalEntryToDatabase(entry, userId: userId)

        try await client
            .from("journal_entries")
            .update(entryData)
            .eq("id", value: entry.id.uuidString)
            .execute()
    }
    func deleteJournalEntry(_ entry: JournalEntry) async throws {
        guard currentUser?.id != nil else {
            throw SupabaseServiceError.notAuthenticated
        }
        if let photoUrl = entry.imageUri {
            try await deletePhoto(url: photoUrl)
        }

        try await client
            .from("journal_entries")
            .delete()
            .eq("id", value: entry.id.uuidString)
            .execute()
    }
    func uploadPhoto(_ imageData: Data, entryId: UUID) async throws -> String {
        guard let userId = currentUser?.id else {
            throw SupabaseServiceError.notAuthenticated
        }
        let filePath = "\(userId.uuidString)/\(entryId.uuidString).jpg"
        try await client.storage
            .from(SupabaseConfig.photoBucketName)
            .upload(filePath, data: imageData, options: FileOptions(contentType: "image/jpeg"))
        let publicURL = try client.storage
            .from(SupabaseConfig.photoBucketName)
            .getPublicURL(path: filePath)

        return publicURL.absoluteString
    }

    private func deletePhoto(url: String) async throws {
        guard let urlComponents = URLComponents(string: url),
              let path = urlComponents.path.split(separator: "/").last else {
            return
        }

        try await client.storage
            .from(SupabaseConfig.photoBucketName)
            .remove(paths: [String(path)])
    }
    func getStreakData() async throws -> StreakData {
        guard let userId = currentUser?.id else {
            throw SupabaseServiceError.notAuthenticated
        }

        let response: [StreakDataDB] = try await client
            .from("streak_data")
            .select()
            .eq("user_id", value: userId.uuidString)
            .execute()
            .value

        if let streakDB = response.first {
            return StreakData(
                currentStreak: streakDB.current_streak,
                longestStreak: streakDB.longest_streak,
                lastEntryDate: ISO8601DateFormatter().date(from: streakDB.last_entry_date) ?? Date()
            )
        } else {
            let initialStreak = StreakData(currentStreak: 0, longestStreak: 0, lastEntryDate: Date())
            try await createStreakData(initialStreak)
            return initialStreak
        }
    }
    private func createStreakData(_ streak: StreakData) async throws {
        guard let userId = currentUser?.id else {
            throw SupabaseServiceError.notAuthenticated
        }

        struct StreakInsert: Encodable {
            let user_id: String
            let current_streak: Int
            let longest_streak: Int
            let last_entry_date: String
        }

        let streakData = StreakInsert(
            user_id: userId.uuidString,
            current_streak: streak.currentStreak,
            longest_streak: streak.longestStreak,
            last_entry_date: ISO8601DateFormatter().string(from: streak.lastEntryDate ?? Date())
        )

        try await client
            .from("streak_data")
            .insert(streakData)
            .execute()
    }
    private func updateStreak() async throws {
        guard let userId = currentUser?.id else {
            throw SupabaseServiceError.notAuthenticated
        }

        var currentStreak = try await getStreakData()

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastEntryDay = calendar.startOfDay(for: currentStreak.lastEntryDate ?? Date())

        let daysDifference = calendar.dateComponents([.day], from: lastEntryDay, to: today).day ?? 0

        if currentStreak.currentStreak == 0 {
            currentStreak.currentStreak = 1
            currentStreak.longestStreak = 1
        } else if daysDifference == 0 {
            return
        } else if daysDifference == 1 {
            currentStreak.currentStreak += 1
        } else {
            currentStreak.currentStreak = 1
        }
        if currentStreak.currentStreak > currentStreak.longestStreak {
            currentStreak.longestStreak = currentStreak.currentStreak
        }

        currentStreak.lastEntryDate = Date()
        struct StreakUpdate: Encodable {
            let current_streak: Int
            let longest_streak: Int
            let last_entry_date: String
        }

        let updates = StreakUpdate(
            current_streak: currentStreak.currentStreak,
            longest_streak: currentStreak.longestStreak,
            last_entry_date: ISO8601DateFormatter().string(from: Date())
        )

        try await client
            .from("streak_data")
            .update(updates)
            .eq("user_id", value: userId.uuidString)
            .execute()
    }
    func saveChatMessage(content: String, isUser: Bool) async throws {
        guard let userId = currentUser?.id else {
            throw SupabaseServiceError.notAuthenticated
        }

        struct ChatMessageInsert: Encodable {
            let user_id: String
            let content: String
            let is_user: Bool
            let timestamp: String
        }

        let message = ChatMessageInsert(
            user_id: userId.uuidString,
            content: content,
            is_user: isUser,
            timestamp: ISO8601DateFormatter().string(from: Date())
        )

        try await client
            .from("chat_messages")
            .insert(message)
            .execute()
    }
    func fetchChatMessages() async throws -> [ChatMessage] {
        guard let userId = currentUser?.id else {
            throw SupabaseServiceError.notAuthenticated
        }

        let response: [ChatMessageDB] = try await client
            .from("chat_messages")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("timestamp", ascending: true)
            .execute()
            .value

        return response.map { ChatMessage(content: $0.content, isUser: $0.is_user) }
    }
    func clearChatHistory() async throws {
        guard let userId = currentUser?.id else {
            throw SupabaseServiceError.notAuthenticated
        }

        try await client
            .from("chat_messages")
            .delete()
            .eq("user_id", value: userId.uuidString)
            .execute()
    }
    private func convertJournalEntryToDatabase(_ entry: JournalEntry, userId: UUID) -> JournalEntryInsert {
        return JournalEntryInsert(
            id: entry.id.uuidString,
            user_id: userId.uuidString,
            content: entry.content,
            journal_type: entry.journalType.rawValue,
            mood_tag: entry.moodTag?.rawValue,
            theme_tags: entry.themeTag != nil ? [entry.themeTag!.rawValue] : nil,
            timestamp: ISO8601DateFormatter().string(from: entry.timestamp),
            created_at: ISO8601DateFormatter().string(from: Date()),
            updated_at: ISO8601DateFormatter().string(from: Date()),
            photo_url: entry.imageUri,
            audio_url: entry.audioUri
        )
    }
    private func convertDatabaseToJournalEntry(_ data: JournalEntryDB) -> JournalEntry? {
        guard let id = UUID(uuidString: data.id),
              let journalType = JournalType(rawValue: data.journal_type),
              let timestamp = ISO8601DateFormatter().date(from: data.timestamp) else {
            return nil
        }

        var moodTag: MoodTag?
        if let moodString = data.mood_tag {
            moodTag = MoodTag(rawValue: moodString)
        }

        var themeTag: ThemeTag?
        if let themeTags = data.theme_tags,
           let firstTheme = themeTags.first {
            themeTag = ThemeTag(rawValue: firstTheme)
        }

        return JournalEntry(
            id: id,
            content: data.content,
            journalType: journalType,
            moodTag: moodTag,
            themeTag: themeTag,
            imageUri: data.photo_url,
            audioUri: data.audio_url,
            aiReflection: nil,
            timestamp: timestamp
        )
    }
}

private struct StreakDataDB: Decodable {
    let current_streak: Int
    let longest_streak: Int
    let last_entry_date: String
}

private struct UserProfile: Codable {
    let id: String
    let email: String?
    let full_name: String?
    let avatar_url: String?
    let created_at: String
    let updated_at: String
}

private struct JournalEntryDB: Decodable {
    let id: String
    let user_id: String
    let content: String
    let journal_type: String
    let mood_tag: String?
    let theme_tags: [String]?
    let timestamp: String
    let created_at: String
    let updated_at: String
    let photo_url: String?
    let audio_url: String?
}

private struct JournalEntryInsert: Encodable {
    let id: String
    let user_id: String
    let content: String
    let journal_type: String
    let mood_tag: String?
    let theme_tags: [String]?
    let timestamp: String
    let created_at: String
    let updated_at: String
    let photo_url: String?
    let audio_url: String?
}

private struct ChatMessageDB: Decodable {
    let id: String?
    let user_id: String
    let content: String
    let is_user: Bool
    let timestamp: String
}

enum SupabaseServiceError: LocalizedError {
    case notAuthenticated
    case signUpFailed
    case signInFailed
    case invalidCredentials
    case networkError
    case databaseError(String)
    case storageError(String)

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "User is not authenticated. Please sign in."
        case .signUpFailed:
            return "Failed to create account. Please try again."
        case .signInFailed:
            return "Failed to sign in. Please check your credentials."
        case .invalidCredentials:
            return "Invalid email or password."
        case .networkError:
            return "Network error. Please check your connection."
        case .databaseError(let message):
            return "Database error: \(message)"
        case .storageError(let message):
            return "Storage error: \(message)"
        }
    }
}

// timeout wrapper thing
func withTaskTimeout<T>(seconds: TimeInterval, operation: @escaping @Sendable () async throws -> T) async rethrows -> T? {
    try await withThrowingTaskGroup(of: T?.self) { group in
        group.addTask {
            try await operation()
        }

        group.addTask {
            try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            return nil
        }
        let result = try await group.next()
        group.cancelAll()
        return result ?? nil
    }
}
