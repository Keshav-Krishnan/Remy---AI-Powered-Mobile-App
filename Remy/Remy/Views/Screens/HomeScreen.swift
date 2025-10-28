//
//  HomeScreen.swift
//  Remy
//
//  Created by Keshav krishnan on 10/17/25.
//

import SwiftUI

struct HomeScreen: View {
    @Binding var showQuickJournal: Bool
    @Binding var selectedTab: Int
    @EnvironmentObject var viewModel: JournalViewModel
    @State private var gratitudeText = ""
    @State private var showJournalTypeSelection = false
    @State private var currentSpotlightIndex = 0
    @State private var showSpotlightCompletion = false
    @State private var carouselDismissed = false
    @State private var showSuccessAnimation = false
    @State private var lastGratitudeDate: Date?
    @State private var showPhotoJournal = false
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }

    private var shouldShowGratitudeCard: Bool {
        guard let lastDate = lastGratitudeDate else { return true }
        let calendar = Calendar.current
        return !calendar.isDateInToday(lastDate)
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 12) {
                        // Top Bar
                        HStack {
                            Text(greeting)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.remyTextPrimary)

                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 50)
                        .padding(.bottom, 16)
                    }
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            colors: [.remyCream, .remyWarmWhite],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    VStack(spacing: 12) {
                        // Compact Streak Card
                        CompactStreakCard(
                            currentStreak: viewModel.streakData.currentStreak,
                            longestStreak: viewModel.streakData.longestStreak,
                            journalEntries: viewModel.entries,
                            showJournalTypeSelection: $showJournalTypeSelection
                        )
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        if shouldShowGratitudeCard {
                            VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "face.smiling")
                                    .font(.system(size: 20))
                                    .foregroundColor(.remyBrown)
                                
                                Text("Daily Gratitude")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(.remyTextPrimary)

                                Spacer()

                                Button("Skip") {}
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.remyTextSecondary)
                            }
                            
                            Text("What's one thing you're grateful for today?")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.remyTextSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            // Compact Text Editor
                            TextEditor(text: $gratitudeText)
                                .font(.system(size: 15))
                                .foregroundColor(.remyTextPrimary)
                                .frame(height: 80)
                                .scrollContentBackground(.hidden)
                                .padding(12)
                                .background(Color.remySoftGray.opacity(0.5))
                                .overlay(
                                    Group {
                                        if gratitudeText.isEmpty {
                                            Text("Write your gratitude here...")
                                                .font(.system(size: 15))
                                                .foregroundColor(.remyTextSecondary.opacity(0.6))
                                                .padding(.horizontal, 17)
                                                .padding(.top, 20)
                                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                                .allowsHitTesting(false)
                                        }
                                    }
                                )
                                .cornerRadius(12)
                            
                            Button(action: {
                                Task {
                                    let entry = JournalEntry(
                                        content: gratitudeText,
                                        journalType: .gratitude,
                                        moodTag: .grateful
                                    )
                                    await viewModel.createEntry(entry)

                                    await MainActor.run {
                                        lastGratitudeDate = Date()
                                        gratitudeText = ""
                                        let impact = UIImpactFeedbackGenerator(style: .medium)
                                        impact.impactOccurred()

                                        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                                            showSuccessAnimation = true
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                            withAnimation {
                                                showSuccessAnimation = false
                                            }
                                        }
                                    }
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "heart.fill")
                                        .font(.system(size: 14))
                                    Text("Save Gratitude")
                                        .font(.system(size: 15, weight: .semibold))
                                }
                                .foregroundColor(gratitudeText.isEmpty ? .remyTextSecondary : .white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 46)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(gratitudeText.isEmpty ? Color.remySoftGray : Color.remyBrown)
                                )
                            }
                            .disabled(gratitudeText.isEmpty)
                        }
                        .padding(18)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
                        .shadow(color: .remyBrown.opacity(0.04), radius: 20, x: 0, y: 10)
                        .padding(.horizontal, 16)
                        }
                        if showSuccessAnimation {
                            VStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.remyGreen, Color(hex: "#6BCF7F")],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 80, height: 80)
                                        .shadow(color: .remyGreen.opacity(0.4), radius: 20, x: 0, y: 10)

                                    Image(systemName: "checkmark")
                                        .font(.system(size: 40, weight: .bold))
                                        .foregroundColor(.white)
                                }

                                Text("Gratitude Saved!")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(.remyTextPrimary)
                            }
                            .padding(.horizontal, 16)
                            .transition(.scale.combined(with: .opacity))
                        }
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Quick Actions")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                                .foregroundColor(.remyTextPrimary)
                                .padding(.horizontal, 16)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                CompactActionCard(
                                    title: "New Entry",
                                    subtitle: "Start journaling",
                                    icon: "pencil",
                                    color: .remyBrown
                                ) {
                                    showJournalTypeSelection = true
                                }
                                
                                CompactActionCard(
                                    title: "Photo Journal",
                                    subtitle: "Capture moments",
                                    icon: "camera.fill",
                                    color: .remyPurple
                                ) {
                                    showPhotoJournal = true
                                }
                                
                                CompactActionCard(
                                    title: "Quick Journal",
                                    subtitle: "Quick thoughts",
                                    icon: "bolt.fill",
                                    color: .remyOrange
                                ) {
                                    showQuickJournal = true
                                }
                                
                                CompactActionCard(
                                    title: "Insights",
                                    subtitle: "View patterns",
                                    icon: "chart.bar.fill",
                                    color: .remyBlue
                                ) {
                                    let impact = UIImpactFeedbackGenerator(style: .medium)
                                    impact.impactOccurred()
                                    selectedTab = 2  // Navigate to Insights tab
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        if !carouselDismissed {
                            JournalSpotlightCarousel(
                                currentIndex: $currentSpotlightIndex,
                                showCompletion: $showSpotlightCompletion,
                                onDismiss: {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        carouselDismissed = true
                                    }
                                }
                            )
                            .padding(.top, 8)
                        }
                        JournalHistorySection()
                            .padding(.top, 8)
                    }
                    .padding(.bottom, 110)
                }
                .background(Color.remyWarmWhite.ignoresSafeArea())
                .ignoresSafeArea(.all, edges: .top)
            }
            .onAppear {
                Task {
                    await viewModel.loadStreak()
                    let gratitudeEntries = viewModel.entries.filter { $0.journalType == .gratitude }
                    if let lastGratitude = gratitudeEntries.first {
                        lastGratitudeDate = lastGratitude.timestamp
                    }
                }
            }
            .onChange(of: viewModel.entries.count) { _, _ in
                Task {
                    await viewModel.loadStreak()
                }
            }
            .sheet(isPresented: $showJournalTypeSelection) {
                JournalTypeSelectionScreen(
                    isPresented: $showJournalTypeSelection,
                    showQuickJournal: $showQuickJournal
                )
                .environmentObject(viewModel)
            }
            .sheet(isPresented: $showPhotoJournal) {
                PhotoJournalScreen(isPresented: $showPhotoJournal)
                    .environmentObject(viewModel)
            }
        }
    }
    struct CompactStreakCard: View {
        let currentStreak: Int
        let longestStreak: Int
        let journalEntries: [JournalEntry]
        @Binding var showJournalTypeSelection: Bool

        private let weekDays = ["S", "M", "T", "W", "T", "F", "S"]

        private var currentDayIndex: Int {
            Calendar.current.component(.weekday, from: Date()) - 1
        }

        // Calculate which days this week have journal entries
        private var completedDays: Set<Int> {
            let calendar = Calendar.current
            let today = Date()

            // Get the start of the current week (Sunday)
            guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start else {
                return []
            }

            var completed = Set<Int>()

            for entry in journalEntries {
                // Get the weekday index (0 = Sunday, 1 = Monday, etc.)
                let entryWeekday = calendar.component(.weekday, from: entry.timestamp) - 1

                // Check if the entry is from this week
                if let entryWeekInterval = calendar.dateInterval(of: .weekOfYear, for: entry.timestamp),
                   entryWeekInterval.start == weekStart {
                    completed.insert(entryWeekday)
                }
            }

            return completed
        }
        
        var body: some View {
            VStack(spacing: 0) {
                VStack(spacing: 12) {
                    // Header
                    HStack {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.remyOrange)
                        
                        Text("Journaling Streak")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(.remyTextPrimary)
                        
                        Spacer()
                        
                        Text("\(currentStreak) days")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.remyOrange)
                    }
                    
                    // Weekly Progress Circles
                    HStack(spacing: 8) {
                        ForEach(0..<7, id: \.self) { index in
                            VStack(spacing: 6) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            completedDays.contains(index)
                                            ? LinearGradient(
                                                colors: [Color.remyOrange, Color.remyPeach],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                            : LinearGradient(
                                                colors: [Color.remySoftGray, Color.remySoftGray],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 36, height: 36)
                                        .shadow(
                                            color: completedDays.contains(index)
                                            ? Color.remyOrange.opacity(0.4)
                                            : Color.clear,
                                            radius: 6,
                                            x: 0,
                                            y: 3
                                        )
                                    
                                    if completedDays.contains(index) {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                    
                                    // Current day indicator
                                    if index == currentDayIndex {
                                        Circle()
                                            .stroke(
                                                LinearGradient(
                                                    colors: [Color.remyBrown, Color.remyDarkBrown],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 2
                                            )
                                            .frame(width: 40, height: 40)
                                    }
                                }
                                
                                Text(weekDays[index])
                                    .font(.system(size: 10, weight: index == currentDayIndex ? .bold : .medium))
                                    .foregroundColor(index == currentDayIndex ? .remyBrown : .remyTextSecondary)
                            }
                        }
                    }
                    
                    Text("Keep your momentum going!")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.remyTextSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(16)
                .background(Color.white)
                
                // Write today button
                Button(action: {
                    showJournalTypeSelection = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "target")
                            .font(.system(size: 14))
                        Text("Write Today")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.remyBrown)
                }
            }
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
            .shadow(color: .remyOrange.opacity(0.1), radius: 20, x: 0, y: 10)
        }
    }
    
    // MARK: - Legacy Modern Streak Card
    struct ModernStreakCard: View {
        let currentStreak: Int
        let longestStreak: Int
        
        var body: some View {
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    VStack(spacing: 8) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.remyOrange)
                        
                        Text("\(currentStreak)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.remyTextPrimary)
                        
                        Text("DAYS")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.remyTextSecondary)
                            .tracking(1)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Divider()
                        .frame(height: 80)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Journaling Streak")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(.remyTextPrimary)
                        
                        Text("Keep your momentum going!")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.remyTextSecondary)
                        
                        HStack(spacing: 8) {
                            Text("\(currentStreak) / 7 days")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.remyTextSecondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(24)
                .background(Color.white)
                
                Button(action: {}) {
                    HStack(spacing: 8) {
                        Image(systemName: "target")
                            .font(.system(size: 16))
                        Text("Write Today")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.remyBrown)
                }
            }
            .cornerRadius(24)
            .shadow(color: .black.opacity(0.06), radius: 16, x: 0, y: 4)
        }
    }
    
    // MARK: - Compact Action Card
    struct CompactActionCard: View {
        let title: String
        let subtitle: String
        let icon: String
        let color: Color
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                VStack(alignment: .leading, spacing: 8) {
                    // Compact Icon
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.12))
                            .frame(width: 38, height: 38)
                        
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(color)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.remyTextPrimary)
                        
                        Text(subtitle)
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(.remyTextSecondary)
                    }
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 110)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
                .shadow(color: color.opacity(0.08), radius: 16, x: 0, y: 8)
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Legacy Modern Action Card
    struct ModernActionCard: View {
        let title: String
        let subtitle: String
        let icon: String
        let color: Color
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                VStack(alignment: .leading, spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.15))
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: icon)
                            .font(.system(size: 20))
                            .foregroundColor(color)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.remyTextPrimary)
                        
                        Text(subtitle)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.remyTextSecondary)
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 140)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Journal Spotlight Carousel
    struct JournalSpotlightCarousel: View {
        @Binding var currentIndex: Int
        @Binding var showCompletion: Bool
        let onDismiss: () -> Void
        @EnvironmentObject var viewModel: JournalViewModel
        @State private var dragOffset: CGFloat = 0
        @State private var completionScale: CGFloat = 0
        @State private var checkmarkOpacity: Double = 0

        // Get real user journal entries
        private var spotlightEntries: [(title: String, preview: String, mood: String, date: String)] {
            let entries = viewModel.entries.prefix(5)
            return entries.map { entry in
                let title = entry.journalType.displayName
                let preview = entry.content
                let mood = entry.moodTag?.icon ?? "📝"
                let date = formatDate(entry.timestamp)
                return (title, preview, mood, date)
            }
        }

        private func formatDate(_ date: Date) -> String {
            let calendar = Calendar.current
            let now = Date()

            if calendar.isDateInToday(date) {
                return "Today"
            } else if calendar.isDateInYesterday(date) {
                return "Yesterday"
            } else if let daysAgo = calendar.dateComponents([.day], from: date, to: now).day {
                if daysAgo < 7 {
                    return "\(daysAgo) days ago"
                } else if daysAgo < 14 {
                    return "1 week ago"
                } else {
                    return "\(daysAgo / 7) weeks ago"
                }
            }
            return "Recently"
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("Journal Spotlight")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.remyTextPrimary)
                    .padding(.horizontal, 16)

                if spotlightEntries.isEmpty {
                    // Empty state - encourage first entry
                    VStack(spacing: 12) {
                        Image(systemName: "star.circle")
                            .font(.system(size: 48))
                            .foregroundColor(.remyBrown.opacity(0.3))

                        Text("Start your journey")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.remyTextPrimary)

                        Text("Create your first journal entry\nto see it featured here")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(.remyTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 180)
                    .background(
                        LinearGradient(
                            colors: [Color.white, Color.remyCream.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
                    .padding(.horizontal, 16)
                } else if spotlightEntries.count < 5 {
                    // Show real entries + encouragement message
                    TabView(selection: $currentIndex) {
                        ForEach(Array(spotlightEntries.enumerated()), id: \.offset) { index, entry in
                            SpotlightCard(
                                title: entry.title,
                                preview: entry.preview,
                                mood: entry.mood,
                                date: entry.date
                            )
                            .tag(index)
                        }

                        // Encouragement card
                        VStack(spacing: 12) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.remyOrange)

                            Text("Keep going!")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.remyTextPrimary)

                            Text("\(5 - spotlightEntries.count) more \(5 - spotlightEntries.count == 1 ? "entry" : "entries") to fill your spotlight")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(.remyTextSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(18)
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                colors: [Color.white, Color.remyCream.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
                        .shadow(color: .remyOrange.opacity(0.1), radius: 20, x: 0, y: 10)
                        .padding(.horizontal, 16)
                        .tag(spotlightEntries.count)
                    }
                    .frame(height: 180)
                    .tabViewStyle(.page(indexDisplayMode: .always))
                } else {
                    // Show 5 real entries
                    TabView(selection: $currentIndex) {
                        ForEach(Array(spotlightEntries.enumerated()), id: \.offset) { index, entry in
                            SpotlightCard(
                                title: entry.title,
                                preview: entry.preview,
                                mood: entry.mood,
                                date: entry.date
                            )
                            .tag(index)
                        }
                    }
                    .frame(height: 180)
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .onChange(of: currentIndex) { oldValue, newValue in
                        if newValue == spotlightEntries.count - 1 && oldValue == spotlightEntries.count - 2 {
                            // Last card reached
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                showCompletionAnimation()
                            }
                        }
                    }
                }
                
                // Completion Animation Overlay
                if showCompletion {
                    VStack {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.remyGreen, Color.remyBlue],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)
                                .scaleEffect(completionScale)
                                .shadow(color: .remyGreen.opacity(0.4), radius: 20, x: 0, y: 10)
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                                .opacity(checkmarkOpacity)
                        }
                        
                        Text("All caught up!")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.remyTextPrimary)
                            .opacity(checkmarkOpacity)
                            .padding(.top, 12)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 180)
                    .background(Color.remyWarmWhite)
                }
            }
        }
        
        private func showCompletionAnimation() {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            
            showCompletion = true
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                completionScale = 1.0
            }
            
            withAnimation(.easeIn(duration: 0.3).delay(0.2)) {
                checkmarkOpacity = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    showCompletion = false
                    completionScale = 0
                    checkmarkOpacity = 0
                }
                // Dismiss the entire carousel after animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onDismiss()
                }
            }
        }
    }
    
    // MARK: - Spotlight Card
    struct SpotlightCard: View {
        let title: String
        let preview: String
        let mood: String
        let date: String
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(mood)
                        .font(.system(size: 28))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.remyTextPrimary)
                            .lineLimit(1)
                        
                        Text(date)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.remyTextSecondary)
                    }
                    
                    Spacer()
                }
                
                Text(preview)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.remyTextSecondary)
                    .lineLimit(4)
                    .multilineTextAlignment(.leading)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [Color.white, Color.remyCream.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
            .shadow(color: .remyBrown.opacity(0.06), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - Journal History Section
    struct JournalHistorySection: View {
        @EnvironmentObject var viewModel: JournalViewModel
        @State private var selectedFilter: JournalType? = nil
        @State private var selectedEntry: JournalEntry? = nil
        @State private var showDetailView = false

        private var filteredEntries: [JournalEntry] {
            let entries = viewModel.entries
            if let selectedFilter {
                return entries.filter { $0.journalType == selectedFilter }
            }
            return entries
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("History")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.remyTextPrimary)
                    .padding(.horizontal, 16)
                
                // Filter Buttons
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        // All button
                        FilterChip(
                            title: "All",
                            isSelected: selectedFilter == nil,
                            color: .remyBrown
                        ) {
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedFilter = nil
                            }
                        }
                        
                        // Type filter buttons
                        ForEach(JournalType.allCases) { type in
                            FilterChip(
                                title: type.displayName,
                                isSelected: selectedFilter == type,
                                color: getColorForType(type)
                            ) {
                                let impact = UIImpactFeedbackGenerator(style: .light)
                                impact.impactOccurred()
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedFilter = type
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                // History Entries List
                VStack(spacing: 10) {
                    if filteredEntries.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "book.closed")
                                .font(.system(size: 48))
                                .foregroundColor(Color(hex: "#8B5A3C").opacity(0.3))

                            Text("No entries yet")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.remyTextPrimary)

                            Text("Start journaling to see your history here")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(.remyTextSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                    } else {
                        ForEach(filteredEntries) { entry in
                            HistoryEntryCard(entry: entry) {
                                let impact = UIImpactFeedbackGenerator(style: .light)
                                impact.impactOccurred()
                                selectedEntry = entry
                                showDetailView = true
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .sheet(isPresented: $showDetailView) {
                if let entry = selectedEntry {
                    JournalDetailView(entry: entry)
                        .presentationDragIndicator(.visible)
                        .presentationBackground(Color(hex: "#FDF8F6"))
                }
            }
        }
        
        private func getColorForType(_ type: JournalType) -> Color {
            switch type {
            case .quick: return .remyOrange
            case .personal: return .remyPurple
            case .photo: return .remyBlue
            case .gratitude: return .remyGreen
            case .goals: return Color(hex: "FF6B35")
            case .reflection: return .remyPurple
            case .dreams: return Color(hex: "9B87F5")
            case .travel: return .remyBlue
            }
        }
    }
    
    // MARK: - Filter Chip
    struct FilterChip: View {
        let title: String
        let isSelected: Bool
        let color: Color
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                Text(title)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? .white : .remyTextPrimary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(isSelected ? color : Color.white)
                            .shadow(
                                color: isSelected ? color.opacity(0.3) : .black.opacity(0.06),
                                radius: isSelected ? 6 : 4,
                                x: 0,
                                y: isSelected ? 3 : 2
                            )
                    )
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - History Entry Card
    struct HistoryEntryCard: View {
        let entry: JournalEntry
        let onTap: () -> Void

        private var wordCount: Int {
            entry.content.split(separator: " ").count
        }

        var body: some View {
            Button(action: onTap) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        // Type icon
                        ZStack {
                            Circle()
                                .fill(getColorForType(entry.journalType).opacity(0.15))
                                .frame(width: 36, height: 36)

                            Image(systemName: entry.journalType.icon)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(getColorForType(entry.journalType))
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            Text(entry.journalType.displayName)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(.remyTextPrimary)

                            Text(entry.timestamp, style: .date)
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                .foregroundColor(.remyTextSecondary)
                        }

                        Spacer()

                        // Mood tag
                        if let mood = entry.moodTag {
                            Text(mood.icon)
                                .font(.system(size: 22))
                        }

                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.remyTextSecondary)
                    }

                    // Preview content
                    Text(entry.content)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.remyTextSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    // Bottom info
                    HStack(spacing: 12) {
                        Label("\(wordCount) words", systemImage: "textformat.size")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(Color(hex: "#8B5A3C"))

                        if let theme = entry.themeTag {
                            HStack(spacing: 4) {
                                Image(systemName: theme.icon)
                                Text(theme.displayName)
                            }
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(theme.color)
                        }

                        Spacer()

                        Text(entry.timestamp, style: .time)
                            .font(.system(size: 11, weight: .regular, design: .rounded))
                            .foregroundColor(.remyTextSecondary)
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
            }
            .buttonStyle(.plain)
        }
        
        private func getColorForType(_ type: JournalType) -> Color {
            switch type {
            case .quick: return .remyOrange
            case .personal: return .remyPurple
            case .photo: return .remyBlue
            case .gratitude: return .remyGreen
            case .goals: return Color(hex: "FF6B35")
            case .reflection: return .remyPurple
            case .dreams: return Color(hex: "9B87F5")
            case .travel: return .remyBlue
            }
        }
    }
    
    // MARK: - Legacy Components
    struct QuickActionButton: View {
        let title: String
        let icon: String
        let gradient: LinearGradient
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                VStack(spacing: .sm) {
                    Image(systemName: icon)
                        .font(.title)
                    Text(title)
                        .font(.remyBody)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 100)
                .background(gradient)
                .clipShape(RoundedRectangle(cornerRadius: .buttonRadius))
            }
        }
    }

#Preview {
    struct PreviewWrapper: View {
        @State private var showQuickJournal = false
        @State private var selectedTab = 0
        @StateObject private var viewModel = JournalViewModel()

        var body: some View {
            HomeScreen(showQuickJournal: $showQuickJournal, selectedTab: $selectedTab)
                .environmentObject(viewModel)
        }
    }

    return PreviewWrapper()
}
