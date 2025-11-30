//
//  TeamIconView.swift
//  PubRanker
//
//  Created on 20.10.2025
//

import SwiftUI

struct TeamIconView: View {
    let team: Team
    let size: CGFloat
    
    init(team: Team, size: CGFloat = 40) {
        self.team = team
        self.size = size
    }
    
    var body: some View {
        Group {
            if let imageData = team.imageData, let nsImage = NSImage(data: imageData) {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
                    .clipShape(Circle())
                    .overlay {
                        Circle()
                            .stroke(Color.white.opacity(0.6), lineWidth: max(1, size / 20))
                    }
                    .shadow(color: Color.black.opacity(0.2), radius: size / 10, x: 0, y: size / 20)
            } else {
                Circle()
                    .fill(Color(hex: team.color) ?? .blue)
                    .frame(width: size, height: size)
                    .overlay {
                        Circle()
                            .stroke(Color.white.opacity(0.6), lineWidth: max(1, size / 20))
                    }
                    .shadow(color: Color(hex: team.color)?.opacity(0.4) ?? .clear, radius: size / 10, x: 0, y: size / 20)
            }
        }
    }
}






