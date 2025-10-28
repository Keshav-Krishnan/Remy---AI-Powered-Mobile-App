//
//  GoalsJournalScreen.swift
//  Remy
//
//  Created by Claude Code on 10/18/25.
//

import SwiftUI

struct GoalsJournalScreen: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var viewModel: JournalViewModel
    
    @State private var goalTitle = ""
    @State private var goalDescription = ""
    @State private var targetDate = Date().addingTimeInterval(30 * 24 * 60 * 60) // 30 days from now
    @State private var goalCategory: GoalCategory = .personal
    @State private var milestones: [String] = [""]
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case title, description, milestone(Int)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Warm background
                Color(hex: "#F7F1E3")
                    .ignoresSafeArea()
                
                // Decorative corner
                CornerEngraving(pattern: .star, corner: .topLeft, opacity: 0.05)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        // Decorative header
                        DecorativeHeader(
                            title: "Set a Goal",
                            subtitle: "Track your progress",
                            pattern: .moon
                        )
                        .padding(.top, 8)
                        
                        VStack(spacing: 24) {
                            // Goal Title
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Goal Title")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(hex: "#4A2C1A"))
                                
                                TextField("e.g., Read 12 books this year", text: $goalTitle)
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(hex: "#2C2C2C"))
                                    .padding(16)
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color(hex: "#E8DCD1"), lineWidth: 1.5)
                                    )
                                    .focused($focusedField, equals: .title)
                            }
                            
                            // Goal Category
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Category")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(hex: "#4A2C1A"))
                                
                                HStack(spacing: 10) {
                                    ForEach(GoalCategory.allCases, id: \.self) { category in
                                        CategoryButton(
                                            category: category,
                                            isSelected: goalCategory == category
                                        ) {
                                            let impact = UIImpactFeedbackGenerator(style: .light)
                                            impact.impactOccurred()
                                            goalCategory = category
                                        }
                                    }
                                }
                            }
                            
                            // Target Date
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Target Completion Date")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(hex: "#4A2C1A"))
                                
                                DatePicker("", selection: $targetDate, in: Date()..., displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                                    .padding(12)
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color(hex: "#E8DCD1"), lineWidth: 1.5)
                                    )
                            }
                            
                            // Goal Description
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Description")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(hex: "#4A2C1A"))
                                
                                TextEditor(text: $goalDescription)
                                    .font(.system(size: 15, weight: .regular, design: .rounded))
                                    .foregroundColor(Color(hex: "#2C2C2C"))
                                    .frame(height: 100)
                                    .scrollContentBackground(.hidden)
                                    .padding(12)
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color(hex: "#E8DCD1"), lineWidth: 1.5)
                                    )
                                    .focused($focusedField, equals: .description)
                                
                                if goalDescription.isEmpty {
                                    Text("Why is this goal important to you?")
                                        .font(.system(size: 14, weight: .regular, design: .rounded))
                                        .foregroundColor(Color(hex: "#8E8E93"))
                                        .padding(.top, -96)
                                        .padding(.leading, 28)
                                        .allowsHitTesting(false)
                                }
                            }
                            
                            // Milestones
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Milestones (Optional)")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color(hex: "#4A2C1A"))
                                    
                                    Spacer()
                                    
                                    Button(action: addMilestone) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "plus.circle.fill")
                                                .font(.system(size: 16))
                                            Text("Add")
                                                .font(.system(size: 14, weight: .medium))
                                        }
                                        .foregroundColor(Color(hex: "#FF6B35"))
                                    }
                                }
                                
                                ForEach(milestones.indices, id: \.self) { index in
                                    HStack(spacing: 12) {
                                        Image(systemName: "flag.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(Color(hex: "#FF6B35"))
                                        
                                        TextField("Milestone \(index + 1)", text: $milestones[index])
                                            .font(.system(size: 15, weight: .regular, design: .rounded))
                                            .foregroundColor(Color(hex: "#2C2C2C"))
                                            .focused($focusedField, equals: .milestone(index))
                                        
                                        if milestones.count > 1 {
                                            Button(action: { removeMilestone(at: index) }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.system(size: 18))
                                                    .foregroundColor(Color(hex: "#8E8E93"))
                                            }
                                        }
                                    }
                                    .padding(12)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(hex: "#E8DCD1"), lineWidth: 1)
                                    )
                                }
                            }
                            
                            // Progress Visualization
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Initial Progress")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(hex: "#4A2C1A"))
                                
                                GoalProgressCard(
                                    title: goalTitle.isEmpty ? "Your Goal" : goalTitle,
                                    category: goalCategory,
                                    targetDate: targetDate,
                                    progress: 0.0
                                )
                            }
                            
                            // Save Button
                            SaveGoalButton(
                                title: goalTitle,
                                description: goalDescription
                            ) {
                                saveGoal()
                            }
                            .padding(.bottom, 40)
                        }
                        .padding(.horizontal, 24)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: "#8B6F4B"))
                    }
                }
            }
        }
    }
    
    private func addMilestone() {
        milestones.append("")
    }
    
    private func removeMilestone(at index: Int) {
        milestones.remove(at: index)
    }
    
    private func saveGoal() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        let milestonesText = milestones.filter { !$0.isEmpty }.enumerated()
            .map { "• \($0.element)" }
            .joined(separator: "\n")

        var contentParts: [String] = []

        // Goal header
        contentParts.append("🎯 \(goalTitle)")
        contentParts.append("")

        // Category and date
        contentParts.append("Category: \(goalCategory.rawValue.capitalized)")
        contentParts.append("Target Date: \(targetDate.formatted(date: .long, time: .omitted))")
        contentParts.append("")

        // Description
        contentParts.append("Description:")
        contentParts.append(goalDescription)

        // Milestones if any
        if !milestonesText.isEmpty {
            contentParts.append("")
            contentParts.append("Milestones:")
            contentParts.append(milestonesText)
        }

        let content = contentParts.joined(separator: "\n")

        Task {
            let entry = JournalEntry(
                content: content,
                journalType: .goals,
                moodTag: .excited
            )
            await viewModel.createEntry(entry)
            isPresented = false
        }
    }
}

// MARK: - Goal Category
enum GoalCategory: String, CaseIterable {
    case personal
    case health
    case career
    case learning
    case creative

    var icon: String {
        switch self {
        case .personal: return "person.fill"
        case .health: return "heart.fill"
        case .career: return "briefcase.fill"
        case .learning: return "book.fill"
        case .creative: return "paintbrush.fill"
        }
    }

    var color: Color {
        switch self {
        case .personal: return Color(hex: "9B87F5")
        case .health: return Color(hex: "6BCF7F")
        case .career: return Color(hex: "FF6B35")
        case .learning: return Color(hex: "74B9FF")
        case .creative: return Color(hex: "FFB8A3")
        }
    }
}

// MARK: - Category Button
struct CategoryButton: View {
    let category: GoalCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.system(size: 18, weight: .medium))

                Text(category.rawValue.capitalized)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
            }
            .foregroundColor(isSelected ? .white : Color(hex: "#4A2C1A"))
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(isSelected ? category.color : Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(category.color, lineWidth: isSelected ? 0 : 1.5)
            )
            .shadow(
                color: isSelected ? category.color.opacity(0.3) : Color.black.opacity(0.04),
                radius: 6,
                x: 0,
                y: 3
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Goal Progress Card
struct GoalProgressCard: View {
    let title: String
    let category: GoalCategory
    let targetDate: Date
    let progress: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: category.icon)
                    .font(.system(size: 16))
                    .foregroundColor(category.color)

                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(hex: "#4A2C1A"))
                    .lineLimit(1)
            }

            // Progress bar
            VStack(alignment: .leading, spacing: 6) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(hex: "#E8DCD1"))
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: [category.color, category.color.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * progress, height: 8)
                    }
                }
                .frame(height: 8)

                HStack {
                    Text("\(Int(progress * 100))% Complete")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(Color(hex: "#8E8E93"))

                    Spacer()

                    Text(targetDate, style: .date)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(Color(hex: "#8E8E93"))
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(category.color.opacity(0.3), lineWidth: 1.5)
        )
        .shadow(color: category.color.opacity(0.1), radius: 12, x: 0, y: 4)
    }
}

// MARK: - Save Goal Button
struct SaveGoalButton: View {
    let title: String
    let description: String
    let action: () -> Void

    private var isEnabled: Bool {
        !title.isEmpty && !description.isEmpty
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: "target")
                    .font(.system(size: 18, weight: .semibold))
                Text("Set Goal")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    colors: isEnabled
                        ? [Color(hex: "#FF6B35"), Color(hex: "#FFB8A3")]
                        : [Color(hex: "#E8DCD1"), Color(hex: "#E8DCD1")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(28)
            .shadow(
                color: isEnabled ? Color(hex: "#FF6B35").opacity(0.3) : Color.clear,
                radius: 15,
                x: 0,
                y: 8
            )
        }
        .disabled(!isEnabled)
    }
}

#Preview {
    GoalsJournalScreen(isPresented: .constant(true))
        .environmentObject(JournalViewModel())
}
