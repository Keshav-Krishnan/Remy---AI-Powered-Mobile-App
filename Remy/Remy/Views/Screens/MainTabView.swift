//
//  MainTabView.swift
//  Remy
//
//  Created by Keshav krishnan on 10/17/25.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var viewModel = JournalViewModel()
    @State private var selectedTab = 0
    @State private var showQuickJournal = false

    var body: some View {
        ZStack {
            // Background to fill entire screen
            Color.remyWarmWhite
                .ignoresSafeArea()

            // Content
            Group {
                switch selectedTab {
                case 0:
                    HomeScreen(showQuickJournal: $showQuickJournal, selectedTab: $selectedTab)
                case 1:
                    JournalScreen()
                case 2:
                    DashboardScreen()
                default:
                    HomeScreen(showQuickJournal: $showQuickJournal, selectedTab: $selectedTab)
                }
            }
            .environmentObject(viewModel)

            // Floating Tab Bar
            VStack {
                Spacer()
                FloatingTabBar(selectedTab: $selectedTab)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
        }
        .sheet(isPresented: $showQuickJournal) {
            QuickJournalScreen(isPresented: $showQuickJournal)
                .environmentObject(viewModel)
        }
        .task {
            await viewModel.loadEntries()
        }
    }
}

// MARK: - Floating Tab Bar
struct FloatingTabBar: View {
    @Binding var selectedTab: Int

    var body: some View {
        HStack(spacing: 0) {
            TabBarButton(
                icon: "house.fill",
                title: "Home",
                isSelected: selectedTab == 0
            ) {
                selectedTab = 0
            }

            TabBarButton(
                icon: "book.closed.fill",
                title: "Journal",
                isSelected: selectedTab == 1
            ) {
                selectedTab = 1
            }

            TabBarButton(
                icon: "chart.bar.fill",
                title: "Insights",
                isSelected: selectedTab == 2
            ) {
                selectedTab = 2
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
        )
    }
}

// MARK: - Tab Bar Button
struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            // Haptic feedback
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            action()
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .frame(height: 24)

                Text(title)
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundColor(isSelected ? .remyBrown : .remyTextSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.remyBrown.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MainTabView()
}
