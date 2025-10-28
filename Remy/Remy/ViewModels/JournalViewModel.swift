//
//  JournalViewModel.swift
//  Remy
//
//  Created by Keshav krishnan on 10/17/25.
//

import Foundation
import SwiftUI

@MainActor
class JournalViewModel: ObservableObject {
    @Published var entries: [JournalEntry] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var streakData = StreakData()

    private let supabaseService = SupabaseService.shared

    init() {
        Task {
            await loadInitialData()
        }
    }
    func loadDataIfNeeded() async {
        guard entries.isEmpty else { return }
        await loadInitialData()
    }
    private func loadInitialData() async {
        guard supabaseService.isAuthenticated else {
            loadMockData()
            return
        }
        await loadEntries()
        await loadStreak()
    }
    func loadEntries() async {
        isLoading = true
        errorMessage = nil

        do {
            entries = try await supabaseService.fetchJournalEntries()
        } catch {
            errorMessage = "Failed to load entries: \(error.localizedDescription)"
            print("[JournalViewModel] Error loading entries: \(error)")
        }

        isLoading = false
    }
    func loadStreak() async {
        do {
            streakData = try await supabaseService.getStreakData()
        } catch {
            errorMessage = "Failed to load streak: \(error.localizedDescription)"
            print("[JournalViewModel] Error loading streak: \(error)")
        }
    }
    func createEntry(_ entry: JournalEntry) async {
        isLoading = true
        errorMessage = nil

        do {
            let savedEntry = try await supabaseService.createJournalEntry(entry)
            entries.insert(savedEntry, at: 0)
            await loadStreak()
        } catch {
            errorMessage = "Failed to create entry: \(error.localizedDescription)"
            print("[JournalViewModel] Error creating entry: \(error)")
        }

        isLoading = false
    }
    func createEntryWithPhoto(_ entry: JournalEntry, photoData: Data) async {
        isLoading = true
        errorMessage = nil

        do {
            let photoUrl = try await supabaseService.uploadPhoto(photoData, entryId: entry.id)
            var updatedEntry = entry
            updatedEntry.imageUri = photoUrl
            let savedEntry = try await supabaseService.createJournalEntry(updatedEntry)
            entries.insert(savedEntry, at: 0)
            await loadStreak()
        } catch {
            errorMessage = "Failed to create entry with photo: \(error.localizedDescription)"
            print("[JournalViewModel] Error creating entry with photo: \(error)")
        }

        isLoading = false
    }
    func updateEntry(_ entry: JournalEntry) async {
        isLoading = true
        errorMessage = nil

        do {
            try await supabaseService.updateJournalEntry(entry)
            if let index = entries.firstIndex(where: { $0.id == entry.id }) {
                entries[index] = entry
            }
        } catch {
            errorMessage = "Failed to update entry: \(error.localizedDescription)"
            print("[JournalViewModel] Error updating entry: \(error)")
        }

        isLoading = false
    }
    func deleteEntry(id: UUID) async {
        isLoading = true
        errorMessage = nil
        guard let entry = entries.first(where: { $0.id == id }) else {
            isLoading = false
            return
        }

        do {
            try await supabaseService.deleteJournalEntry(entry)
            entries.removeAll { $0.id == id }
        } catch {
            errorMessage = "Failed to delete entry: \(error.localizedDescription)"
            print("[JournalViewModel] Error deleting entry: \(error)")
        }

        isLoading = false
    }

    func entriesForType(_ type: JournalType) -> [JournalEntry] {
        entries.filter { $0.journalType == type }
    }

    func entriesForDate(_ date: Date) -> [JournalEntry] {
        let calendar = Calendar.current
        return entries.filter { calendar.isDate($0.timestamp, inSameDayAs: date) }
    }

    private func loadMockData() {
        let mockEntries = [
            JournalEntry(
                content: "Today was a great day! I finished my project and felt really accomplished.",
                journalType: .quick,
                moodTag: .happy,
                themeTag: .work,
                timestamp: Date()
            ),
            JournalEntry(
                content: "Feeling grateful for my family and friends who always support me.",
                journalType: .gratitude,
                moodTag: .grateful,
                themeTag: .family,
                timestamp: Date().addingTimeInterval(-86400)
            ),
            JournalEntry(
                content: "Had a tough day at work, feeling a bit stressed about upcoming deadlines.",
                journalType: .personal,
                moodTag: .stressed,
                themeTag: .work,
                timestamp: Date().addingTimeInterval(-172800)
            )
        ]

        self.entries = mockEntries
        self.streakData = StreakData(currentStreak: 3, longestStreak: 7)
    }
}
