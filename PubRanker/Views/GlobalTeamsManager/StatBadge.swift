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
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.title3)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title3)
                    .bold()
                    .monospacedDigit()
                    .foregroundStyle(.primary)
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.1))
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                }
        )
    }
}

