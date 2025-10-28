//
//  JournalViewModel.swift
//  Remy
//
//  Created on 10/17/25.
//

import Foundation
import Combine

@MainActor
class JournalViewModel: ObservableObject {
    @Published var entries: [JournalEntry] = []
    @Published var currentEntry: JournalEntry?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var filteredEntries: [JournalEntry] = []
    @Published var selectedFilter: JournalType?
    @Published var streakData: StreakData = StreakData(currentStreak: 0, longestStreak: 0, lastEntryDate: nil)

    private var cancellables = Set<AnyCancellable>()

    init() {
        setupFilterObservation()
    }
    func loadEntries() async {
        isLoading = true
        errorMessage = nil

        do {
            // wire up firebase later
            entries = []

            applyFilter()
        } catch {
            errorMessage = "Failed to load entries: \(error.localizedDescription)"
        }

        isLoading = false
    }
    func createEntry(_ entry: JournalEntry) async {
        isLoading = true
        errorMessage = nil

        do {
            var updatedEntry = entry
            updatedEntry.timestamp = Date()
            entries.insert(updatedEntry, at: 0)
            applyFilter()

            successMessage = "Entry saved successfully!"
            await updateStreak()

        } catch {
            errorMessage = "Failed to create entry: \(error.localizedDescription)"
        }

        isLoading = false
    }
    func updateEntry(_ entry: JournalEntry) async {
        isLoading = true
        errorMessage = nil

        do {
            if let index = entries.firstIndex(where: { $0.id == entry.id }) {
                entries[index] = entry
                applyFilter()
            }

            successMessage = "Entry updated!"

        } catch {
            errorMessage = "Failed to update entry: \(error.localizedDescription)"
        }

        isLoading = false
    }
    func deleteEntry(id: UUID) async {
        isLoading = true
        errorMessage = nil

        do {
            entries.removeAll { $0.id == id }
            applyFilter()

            successMessage = "Entry deleted"

        } catch {
            errorMessage = "Failed to delete entry: \(error.localizedDescription)"
        }

        isLoading = false
    }
    func analyzeWithAI(content: String) async -> AIReflection? {
        guard !content.isEmpty else { return nil }

        do {
            return AIReflection(
                summary: "This is a mock AI reflection. Connect OpenAI to see real insights.",
                dominantEmotion: "neutral",
                followUp: "How does this reflection make you feel?",
                personalizedInsight: nil,
                moodTrend: nil,
                growthSuggestion: nil
            )

        } catch {
            errorMessage = "AI analysis failed: \(error.localizedDescription)"
            return nil
        }
    }
    func setFilter(_ filter: JournalType?) {
        selectedFilter = filter
        applyFilter()
    }
    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }
    private func applyFilter() {
        if let filter = selectedFilter {
            filteredEntries = entries.filter { $0.journalType == filter }
        } else {
            filteredEntries = entries
        }
    }
    private func setupFilterObservation() {
        $selectedFilter
            .sink { [weak self] _ in
                self?.applyFilter()
            }
            .store(in: &cancellables)
    }

    private func createUserContext() -> UserContext {
        let recentMoods = entries.prefix(10).compactMap { $0.moodTag?.rawValue }
        let recentThemes = entries.prefix(10).compactMap { $0.themeTag?.rawValue }

        return UserContext(
            displayName: "User",
            totalEntries: entries.count,
            currentStreak: 0,
            journalingFrequency: "when-needed",
            journalingGoal: "self-reflection",
            expressionPreference: "writing",
            moodHistory: recentMoods,
            themeHistory: recentThemes
        )
    }

    private func updateStreak() async {
        // wire this up eventually
    }
}

// context for ai stuff
struct UserContext {
    let displayName: String
    let totalEntries: Int
    let currentStreak: Int
    let journalingFrequency: String
    let journalingGoal: String
    let expressionPreference: String
    let moodHistory: [String]
    let themeHistory: [String]
}
