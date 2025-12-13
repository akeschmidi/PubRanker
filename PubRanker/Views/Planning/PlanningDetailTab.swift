//
//  PlanningDetailTab.swift
//  PubRanker
//
//  Created on 23.11.2025
//

import SwiftUI

enum PlanningDetailTab: String, CaseIterable, Identifiable {
    case overview
    case teams
    case rounds
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .overview: return "Übersicht"
        case .teams: return "Teams"
        case .rounds: return "Runden"
        }
    }
    
    var icon: String {
        switch self {
        case .overview: return "chart.bar.fill"
        case .teams: return "person.3.fill"
        case .rounds: return "list.number"
        }
    }
}








