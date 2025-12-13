//
//  TeamSortOption.swift
//  PubRanker
//
//  Created on 23.11.2025
//

import SwiftUI

enum TeamSortOption: String, CaseIterable {
    case nameAscending = "Name (A-Z)"
    case nameDescending = "Name (Z-A)"
    case dateNewest = "Neueste zuerst"
    case dateOldest = "Älteste zuerst"
    case mostQuizzes = "Meiste Zuordnungen"
    case leastQuizzes = "Wenigste Zuordnungen"
    
    var icon: String {
        switch self {
        case .nameAscending, .nameDescending:
            return "textformat.abc"
        case .dateNewest, .dateOldest:
            return "calendar"
        case .mostQuizzes, .leastQuizzes:
            return "link.circle"
        }
    }
}





