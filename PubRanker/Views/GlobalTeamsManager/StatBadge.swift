//
//  StatBadge.swift
//  PubRanker
//
//  Created on 23.11.2025
//

import SwiftUI

struct StatBadge: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.title3)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: AppSpacing.xxxs) {
                Text(value)
                    .font(.title3)
                    .bold()
                    .monospacedDigit()
                    .foregroundStyle(color)
                Text(label)
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppSpacing.xs)
        .padding(.vertical, AppSpacing.xs)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                .fill(color.opacity(0.1))
                .overlay {
                    RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                }
        )
    }
}





