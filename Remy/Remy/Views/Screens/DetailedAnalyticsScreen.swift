//
//  DetailedAnalyticsScreen.swift
//  Remy
//
//  Created by Keshav krishnan on 10/17/25.
//

import SwiftUI

struct DetailedAnalyticsScreen: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: JournalViewModel
    @State private var selectedView: AnalyticsView = .weekly
    @State private var weeklyAnimationProgress: CGFloat = 0
    @State private var monthlyAnimationProgress: CGFloat = 0

    enum AnalyticsView: String, CaseIterable {
        case weekly = "Weekly"
        case monthly = "Monthly"
    }

    // Calculate weekly data from real entries
    private var weeklyData: [(label: String, count: Int)] {
        let calendar = Calendar.current
        let today = Date()

        // Get last 6 weeks
        var data: [(label: String, count: Int)] = []
        for weekOffset in (0..<6).reversed() {
            guard let weekStart = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: today),
                  let weekInterval = calendar.dateInterval(of: .weekOfYear, for: weekStart) else {
                continue
            }

            let count = viewModel.entries.filter { entry in
                weekInterval.contains(entry.timestamp)
            }.count

            data.append(("Week \(6 - weekOffset)", count))
        }

        return data
    }

    // Calculate monthly data from real entries
    private var monthlyData: [(label: String, count: Int)] {
        let calendar = Calendar.current
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"

        // Get last 6 months
        var data: [(label: String, count: Int)] = []
        for monthOffset in (0..<6).reversed() {
            guard let monthStart = calendar.date(byAdding: .month, value: -monthOffset, to: today),
                  let monthInterval = calendar.dateInterval(of: .month, for: monthStart) else {
                continue
            }

            let count = viewModel.entries.filter { entry in
                monthInterval.contains(entry.timestamp)
            }.count

            let label = dateFormatter.string(from: monthStart)
            data.append((label, count))
        }

        return data
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Detailed Analytics")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(.remyTextPrimary)

                                Text("Track your journaling patterns")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.remyTextSecondary)
                            }

                            Spacer()

                            Button(action: {
                                dismiss()
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

                    // View Selector
                    HStack(spacing: 12) {
                        ForEach(AnalyticsView.allCases, id: \.self) { view in
                            Button(action: {
                                let impact = UIImpactFeedbackGenerator(style: .light)
                                impact.impactOccurred()
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedView = view
                                }
                            }) {
                                Text(view.rawValue)
                                    .font(.system(size: 15, weight: selectedView == view ? .semibold : .medium))
                                    .foregroundColor(selectedView == view ? .white : .remyTextPrimary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(selectedView == view ? Color.remyBrown : Color.white)
                                    )
                                    .shadow(
                                        color: selectedView == view ? .remyBrown.opacity(0.3) : .black.opacity(0.03),
                                        radius: selectedView == view ? 8 : 4,
                                        x: 0,
                                        y: selectedView == view ? 4 : 2
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)

                    // Graph Content
                    VStack(spacing: 12) {
                        if selectedView == .weekly {
                            WeeklyGraph(
                                data: weeklyData,
                                animationProgress: weeklyAnimationProgress
                            )
                            .padding(.top, 20)
                        } else {
                            MonthlyGraph(
                                data: monthlyData,
                                animationProgress: monthlyAnimationProgress
                            )
                            .padding(.top, 20)
                        }

                        // Summary Stats
                        SummaryStatsCard(
                            totalEntries: selectedView == .weekly
                                ? weeklyData.map(\.count).reduce(0, +)
                                : monthlyData.map(\.count).reduce(0, +),
                            average: selectedView == .weekly
                                ? weeklyData.map(\.count).reduce(0, +) / weeklyData.count
                                : monthlyData.map(\.count).reduce(0, +) / monthlyData.count,
                            timeFrame: selectedView.rawValue
                        )
                        .padding(.horizontal, 16)
                    }
                    .padding(.bottom, 40)
                }
            }
            .background(Color.remyWarmWhite.ignoresSafeArea())
            .onAppear {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1)) {
                    weeklyAnimationProgress = 1.0
                    monthlyAnimationProgress = 1.0
                }
            }
        }
    }
}

// MARK: - Weekly Graph
struct WeeklyGraph: View {
    let data: [(label: String, count: Int)]
    let animationProgress: CGFloat

    private var maxCount: Int {
        data.map(\.count).max() ?? 1
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Entries by Week")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(.remyTextPrimary)
                .padding(.horizontal, 16)

            HStack(alignment: .bottom, spacing: 10) {
                ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                    VStack(spacing: 8) {
                        // Count label
                        Text("\(item.count)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.remyBrown)
                            .opacity(animationProgress)

                        // Bar
                        ZStack(alignment: .bottom) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.remySoftGray)
                                .frame(height: 160)

                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.remyBrown, Color.remyLightBrown],
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                )
                                .frame(height: max(20, 160 * (CGFloat(item.count) / CGFloat(maxCount))) * animationProgress)
                        }
                        .frame(maxWidth: .infinity)

                        // Label
                        Text(item.label)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.remyTextSecondary)
                    }
                }
            }
            .frame(height: 200)
            .padding(.horizontal, 16)
        }
        .padding(18)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
        .shadow(color: .remyBrown.opacity(0.08), radius: 16, x: 0, y: 8)
        .padding(.horizontal, 16)
    }
}


struct MonthlyGraph: View {
    let data: [(label: String, count: Int)]
    let animationProgress: CGFloat

    private var maxCount: Int {
        data.map(\.count).max() ?? 1
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Entries by Month")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(.remyTextPrimary)
                .padding(.horizontal, 16)

            HStack(alignment: .bottom, spacing: 10) {
                ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                    VStack(spacing: 8) {
                        // Count label
                        Text("\(item.count)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.remyBrown)
                            .opacity(animationProgress)

                        // Bar
                        ZStack(alignment: .bottom) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.remySoftGray)
                                .frame(height: 160)

                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.remyBrown, Color.remyLightBrown],
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                )
                                .frame(height: max(20, 160 * (CGFloat(item.count) / CGFloat(maxCount))) * animationProgress)
                        }
                        .frame(maxWidth: .infinity)

                        // Label
                        Text(item.label)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.remyTextSecondary)
                    }
                }
            }
            .frame(height: 200)
            .padding(.horizontal, 16)
        }
        .padding(18)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
        .shadow(color: .remyBrown.opacity(0.08), radius: 16, x: 0, y: 8)
        .padding(.horizontal, 16)
    }
}

// MARK: - Summary Stats Card
struct SummaryStatsCard: View {
    let totalEntries: Int
    let average: Int
    let timeFrame: String

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Total Entries")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.remyTextSecondary)

                    Text("\(totalEntries)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.remyTextPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.remyOrange.opacity(0.1))
                )

                VStack(alignment: .leading, spacing: 8) {
                    Text("Average/\(timeFrame == "Weekly" ? "Week" : "Month")")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.remyTextSecondary)

                    Text("\(average)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.remyTextPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.remyBlue.opacity(0.1))
                )
            }
        }
        .padding(18)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
    }
}

#Preview {
    DetailedAnalyticsScreen()
        .environmentObject(JournalViewModel())
}
