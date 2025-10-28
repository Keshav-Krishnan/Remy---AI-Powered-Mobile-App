//
//  JournalTypeSelectionScreen.swift
//  Remy
//
//  Created by Keshav krishnan on 10/17/25.
//

import SwiftUI

struct JournalTypeSelectionScreen: View {
    @Binding var isPresented: Bool
    @Binding var showQuickJournal: Bool
    @EnvironmentObject var viewModel: JournalViewModel

    @State private var showPhotoJournal = false
    @State private var showGoalsJournal = false
    @State private var showReflectionJournal = false
    @State private var showDreamsJournal = false

    private let journalTypes = [
        JournalTypeOption(
            title: "Daily Gratitude",
            subtitle: "Express thankfulness",
            icon: "heart.fill",
            color: Color.remyGreen,
            type: .gratitude
        ),
        JournalTypeOption(
            title: "Quick Journal",
            subtitle: "Quick thoughts",
            icon: "bolt.fill",
            color: Color.remyOrange,
            type: .quick
        ),
        JournalTypeOption(
            title: "Personal Reflection",
            subtitle: "Deep thoughts",
            icon: "brain.head.profile",
            color: Color.remyPurple,
            type: .personal
        ),
        JournalTypeOption(
            title: "Photo Journal",
            subtitle: "Capture moments",
            icon: "camera.fill",
            color: Color.remyBlue,
            type: .photo
        ),
        JournalTypeOption(
            title: "Goals",
            subtitle: "Track progress",
            icon: "target",
            color: Color(hex: "FF6B35"),
            type: .goals
        ),
        JournalTypeOption(
            title: "Dream Journal",
            subtitle: "Record dreams",
            icon: "moon.stars.fill",
            color: Color(hex: "9B87F5"),
            type: .dreams
        )
    ]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Start Journaling")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(.remyTextPrimary)

                                Text("Choose your journal type")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.remyTextSecondary)
                            }

                            Spacer()

                            Button(action: {
                                isPresented = false
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.remyTextSecondary)
                                    .frame(width: 32, height: 32)
                                    .background(Color.remySoftGray)
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 16)
                    }
                    .background(
                        LinearGradient(
                            colors: [.remyCream, .remyWarmWhite],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                    // Journal Type Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(journalTypes) { option in
                            JournalTypeCard(option: option) {
                                // Handle selection based on journal type
                                switch option.type {
                                case .quick, .gratitude:
                                    isPresented = false
                                    showQuickJournal = true
                                case .photo:
                                    showPhotoJournal = true
                                case .goals:
                                    showGoalsJournal = true
                                case .reflection:
                                    showReflectionJournal = true
                                case .dreams:
                                    showDreamsJournal = true
                                case .personal:
                                    showReflectionJournal = true
                                case .travel:
                                    // Travel journal - can add later
                                    isPresented = false
                                    showQuickJournal = true
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
            .background(Color.remyWarmWhite.ignoresSafeArea())
            .sheet(isPresented: $showPhotoJournal) {
                PhotoJournalScreen(isPresented: $showPhotoJournal)
                    .environmentObject(viewModel)
            }
            .sheet(isPresented: $showGoalsJournal) {
                GoalsJournalScreen(isPresented: $showGoalsJournal)
                    .environmentObject(viewModel)
            }
            .sheet(isPresented: $showReflectionJournal) {
                ReflectionJournalScreen(isPresented: $showReflectionJournal)
                    .environmentObject(viewModel)
            }
            .sheet(isPresented: $showDreamsJournal) {
                DreamsJournalScreen(isPresented: $showDreamsJournal)
                    .environmentObject(viewModel)
            }
        }
    }
}

// MARK: - Journal Type Card
struct JournalTypeCard: View {
    let option: JournalTypeOption
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            action()
        }) {
            VStack(alignment: .leading, spacing: 14) {
                // Icon
                ZStack {
                    Circle()
                        .fill(option.color.opacity(0.15))
                        .frame(width: 50, height: 50)

                    Image(systemName: option.icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(option.color)
                }

                Spacer()

                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(option.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.remyTextPrimary)
                        .lineLimit(2)

                    Text(option.subtitle)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.remyTextSecondary)
                        .lineLimit(1)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 140)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
            .shadow(color: option.color.opacity(0.08), radius: 16, x: 0, y: 8)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Journal Type Option Model
struct JournalTypeOption: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let type: JournalType
}

#Preview {
    struct PreviewWrapper: View {
        @State private var isPresented = true
        @State private var showQuickJournal = false

        var body: some View {
            JournalTypeSelectionScreen(
                isPresented: $isPresented,
                showQuickJournal: $showQuickJournal
            )
        }
    }

    return PreviewWrapper()
}
