//
//  PlanningDetailTab.swift
//  PubRanker
//
//  Created on 23.11.2025
//

import SwiftUI

enum PlanningDetailTab: String, CaseIterable, Identifiable {
    case overview = "Übersicht"
    case teams = "Teams"
    case rounds = "Runden"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .overview: return "chart.bar.fill"
        case .teams: return "person.3.fill"
        case .rounds: return "list.number"
        }
    }
}





