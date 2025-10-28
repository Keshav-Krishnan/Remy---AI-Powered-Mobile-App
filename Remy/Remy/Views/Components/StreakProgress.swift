//
//  StreakProgress.swift
//  Remy
//
//  Created by Keshav krishnan on 10/17/25.
//

import SwiftUI

struct StreakProgress: View {
    let currentStreak: Int
    let longestStreak: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: .lg) {
                // Current Streak
                HStack(spacing: .sm) {
                    Text("🔥")
                        .font(.system(size: 32))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(currentStreak)")
                            .font(.remyTitle)
                            .foregroundColor(.orange)
                        Text("Current Streak")
                            .font(.remyCaption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                // Longest Streak
                HStack(spacing: .sm) {
                    Text("🏆")
                        .font(.system(size: 32))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(longestStreak)")
                            .font(.remyTitle)
                            .foregroundColor(.yellow)
                        Text("Longest Streak")
                            .font(.remyCaption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.lg)
            .background(
                LinearGradient(
                    colors: [Color.orange.opacity(0.1), Color.yellow.opacity(0.1)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: .cardRadius))
            .remyCardShadow()
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    StreakProgress(currentStreak: 7, longestStreak: 14, onTap: {})
        .padding()
}
