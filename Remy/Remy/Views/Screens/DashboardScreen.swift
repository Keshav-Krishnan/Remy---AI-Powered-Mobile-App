//
//  DashboardScreen.swift
//  Remy
//
//  Created by Keshav krishnan on 10/17/25.
//

import SwiftUI

struct DashboardScreen: View {
    @EnvironmentObject var viewModel: JournalViewModel
    @EnvironmentObject var supabaseService: SupabaseService
    @State private var showDeleteAccountAlert = false
    @State private var showDetailedAnalytics = false
    @State private var showSettings = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true

    private var totalEntries: Int {
        viewModel.entries.count
    }

    private var currentStreak: Int {
        viewModel.streakData.currentStreak
    }

    private var daysJournaled: Int {
        // Count unique days with entries
        let calendar = Calendar.current
        let uniqueDays = Set(viewModel.entries.map { calendar.startOfDay(for: $0.timestamp) })
        return uniqueDays.count
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // Compact Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Your Insights")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.remyTextPrimary)

                            Text("\(totalEntries) entries")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.remyTextSecondary)
                        }

                        Spacer()

                        Button(action: {
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                            showSettings = true
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.remyBrown)
                                .frame(width: 36, height: 36)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 50)
                .padding(.bottom, 16)
                .background(
                    LinearGradient(
                        colors: [.remyCream, .remyWarmWhite],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

                // Main Content - More Compact
                VStack(spacing: 12) {
                    // Compact Journaling Streak Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "flame.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.remyOrange)

                            Text("Journaling Streak")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.remyTextPrimary)
                        }

                        Text("Keep your momentum going!")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.remyTextSecondary)

                        // Compact Progress Bar
                        VStack(alignment: .leading, spacing: 6) {
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.remySoftGray)
                                        .frame(height: 10)

                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(
                                            LinearGradient(
                                                colors: [.remyOrange, .remyPeach],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: geometry.size.width * min(CGFloat(currentStreak) / 7.0, 1.0), height: 10)
                                }
                            }
                            .frame(height: 10)

                            Text("\(currentStreak) / 7 days")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.remyTextSecondary)
                        }
                    }
                    .padding(18)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.03), radius: 10, x: 0, y: 4)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    // Compact Key Statistics Grid
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Key Statistics")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(.remyTextPrimary)
                            .padding(.horizontal, 16)

                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 10) {
                            CompactStatCard(
                                title: "Total Entries",
                                value: "\(totalEntries)",
                                icon: "book.fill",
                                iconColor: .remyBrown,
                                bgColor: Color.remyBrown.opacity(0.1)
                            )

                            CompactStatCard(
                                title: "Days Journaled",
                                value: "\(daysJournaled)",
                                icon: "calendar",
                                iconColor: .remyBlue,
                                bgColor: Color.remyBlue.opacity(0.1)
                            )

                            CompactStatCard(
                                title: "Current Streak",
                                value: "\(currentStreak)",
                                icon: "target",
                                iconColor: .remyOrange,
                                bgColor: Color.remyOrange.opacity(0.1)
                            )

                            CompactStatCard(
                                title: "Longest Streak",
                                value: "\(viewModel.streakData.longestStreak)",
                                icon: "trophy.fill",
                                iconColor: .remyPurple,
                                bgColor: Color.remyPurple.opacity(0.1)
                            )
                        }
                        .padding(.horizontal, 16)
                    }

                    // Journal Activity Graph
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Journal Activity")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                                .foregroundColor(.remyTextPrimary)

                            Spacer()

                            Button(action: {
                                let impact = UIImpactFeedbackGenerator(style: .medium)
                                impact.impactOccurred()
                                showDetailedAnalytics = true
                            }) {
                                HStack(spacing: 4) {
                                    Text("View Details")
                                        .font(.system(size: 12, weight: .medium))
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 10, weight: .semibold))
                                }
                                .foregroundColor(.remyBrown)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.remyBrown.opacity(0.1))
                                )
                            }
                        }
                        .padding(.horizontal, 16)

                        WeeklyActivityGraph(entries: viewModel.entries)
                            .padding(.horizontal, 16)
                    }
                }
                .padding(.bottom, 110)
            }
        }
        .background(Color.remyWarmWhite.ignoresSafeArea())
        .ignoresSafeArea(.all, edges: .top)
        .onAppear {
            Task {
                await viewModel.loadStreak()
            }
        }
        .onChange(of: viewModel.entries.count) { _, _ in
            // Reload streak when entries change
            Task {
                await viewModel.loadStreak()
            }
        }
        .sheet(isPresented: $showDetailedAnalytics) {
            DetailedAnalyticsScreen()
        }
        .sheet(isPresented: $showSettings) {
            SettingsSheet(showDeleteAccountAlert: $showDeleteAccountAlert)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .alert("Delete Account", isPresented: $showDeleteAccountAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    do {
                        try await supabaseService.deleteAccount()
                        // Reset onboarding flag to go back to beginning
                        hasCompletedOnboarding = false
                    } catch {
                        print("Error deleting account: \(error.localizedDescription)")
                    }
                }
            }
        } message: {
            Text("Are you sure you want to permanently delete your account? This action cannot be undone.")
        }
    }
}

// MARK: - Settings Sheet
struct SettingsSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var showDeleteAccountAlert: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#F7F1E3")
                    .ignoresSafeArea()

                // Decorative corner
                CornerEngraving(pattern: .leaf, corner: .topRight, opacity: 0.06)

                ScrollView {
                    VStack(spacing: 24) {
                        // Decorative header
                        DecorativeHeader(
                            title: "Settings",
                            subtitle: "Manage your account",
                            pattern: .moon
                        )
                        .padding(.top, 8)

                        // Delete Account Button
                        VStack(spacing: 12) {
                            Button(action: {
                                dismiss()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    showDeleteAccountAlert = true
                                }
                            }) {
                                HStack(spacing: 14) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.red.opacity(0.1))
                                            .frame(width: 44, height: 44)

                                        Image(systemName: "trash.fill")
                                            .font(.system(size: 18, weight: .medium))
                                            .foregroundColor(.red)
                                    }

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Delete Account")
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                            .foregroundColor(.red)

                                        Text("Permanently delete your account")
                                            .font(.system(size: 13, weight: .regular, design: .rounded))
                                            .foregroundColor(Color(hex: "#8E8E93"))
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Color(hex: "#8E8E93"))
                                }
                                .padding(18)
                                .background(Color.white)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.red.opacity(0.15), lineWidth: 1.5)
                                )
                                .shadow(color: Color(hex: "#6B4F3B").opacity(0.06), radius: 12, x: 0, y: 4)
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: "#8B6F4B"))
                    }
                }
            }
        }
    }
}

// MARK: - Settings Row
struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 44, height: 44)

                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(iconColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(hex: "#4A2C1A"))

                    Text(subtitle)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(Color(hex: "#8E8E93"))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "#8E8E93"))
            }
            .padding(18)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color(hex: "#6B4F3B").opacity(0.06), radius: 12, x: 0, y: 4)
        }
    }
}

// MARK: - Compact Stat Card
struct CompactStatCard: View {
    let title: String
    let value: String
    let icon: String
    let iconColor: Color
    let bgColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Compact Icon
            ZStack {
                Circle()
                    .fill(bgColor)
                    .frame(width: 38, height: 38)

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(iconColor)
            }

            Spacer()

            // Compact Value and Title
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.remyTextPrimary)

                Text(title)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.remyTextSecondary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 120)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 3)
    }
}

// MARK: - Legacy Modern Stat Card
struct ModernStatCard: View {
    let title: String
    let value: String
    let icon: String
    let iconColor: Color
    let bgColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ZStack {
                Circle()
                    .fill(bgColor)
                    .frame(width: 48, height: 48)

                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(iconColor)
            }

            Spacer()

            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.remyTextPrimary)

                Text(title)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.remyTextSecondary)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 160)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
    }
}

// MARK: - Legacy Component
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: .sm) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Spacer()
            }

            Text(value)
                .font(.remyTitle)
                .foregroundColor(.primary)

            Text(title)
                .font(.remyCaption)
                .foregroundColor(.secondary)
        }
        .padding(.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: .cardRadius))
        .remyCardShadow()
    }
}

// MARK: - Weekly Activity Graph
struct WeeklyActivityGraph: View {
    let entries: [JournalEntry]

    @State private var animationProgress: CGFloat = 0

    private var weekData: [(day: String, count: Int)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Get the start of the week (Monday)
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday == 1 ? 6 : weekday - 2) // Adjust for Monday as start
        guard let startOfWeek = calendar.date(byAdding: .day, value: -daysFromMonday, to: today) else {
            return []
        }

        // Count entries for each day of the week
        let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        return days.enumerated().map { index, day in
            guard let date = calendar.date(byAdding: .day, value: index, to: startOfWeek) else {
                return (day, 0)
            }

            let count = entries.filter { entry in
                calendar.isDate(entry.timestamp, inSameDayAs: date)
            }.count

            return (day, count)
        }
    }

    private var maxCount: Int {
        weekData.map(\.count).max() ?? 1
    }

    var body: some View {
        VStack(spacing: 16) {
            // Bar Chart
            HStack(alignment: .bottom, spacing: 12) {
                ForEach(Array(weekData.enumerated()), id: \.offset) { index, data in
                    VStack(spacing: 8) {
                        // Count label
                        Text("\(data.count)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(data.count > 0 ? .remyBrown : .remyTextSecondary.opacity(0.5))
                            .opacity(animationProgress)

                        // Bar
                        ZStack(alignment: .bottom) {
                            // Background bar
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.remySoftGray)
                                .frame(height: 120)

                            // Animated bar
                            RoundedRectangle(cornerRadius: 6)
                                .fill(
                                    LinearGradient(
                                        colors: data.count > 0
                                            ? [Color.remyOrange, Color.remyPeach]
                                            : [Color.remySoftGray, Color.remySoftGray],
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                )
                                .frame(height: max(20, 120 * (CGFloat(data.count) / CGFloat(maxCount))) * animationProgress)
                        }
                        .frame(maxWidth: .infinity)

                        // Day label
                        Text(data.day)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.remyTextSecondary)
                    }
                }
            }
            .frame(height: 160)
        }
        .padding(18)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
        .shadow(color: .remyOrange.opacity(0.08), radius: 16, x: 0, y: 8)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                animationProgress = 1.0
            }
        }
    }
}

#Preview {
    DashboardScreen()
}
