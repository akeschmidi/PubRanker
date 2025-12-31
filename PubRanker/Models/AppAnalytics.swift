//
//  AppAnalytics.swift
//  PubRanker
//
//  Created on 20.12.2025
//

import Foundation
import SwiftData
import CloudKit

/// Anonymisierte App-Nutzungsstatistiken für Remote-Dashboard
@Model
final class AppAnalytics {
    var id: UUID = UUID()
    var timestamp: Date = Date()
    
    // Events
    var quizCreated: Bool = false
    var teamCreated: Bool = false
    var roundCreated: Bool = false
    var scoreEntered: Bool = false
    var quizCompleted: Bool = false
    
    // Aggregierte Werte (anonymisiert)
    var totalQuizzes: Int = 0
    var totalTeams: Int = 0
    var totalRounds: Int = 0
    var totalPoints: Int = 0
    
    // App Info
    var appVersion: String = ""
    var platform: String = "macOS"
    
    init() {
        self.timestamp = Date()
        self.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}

// MARK: - Analytics Service
class AnalyticsService {
    static let shared = AnalyticsService()
    
    private let container: CKContainer
    private let publicDatabase: CKDatabase
    
    private init() {
        // Verwende den gleichen Container wie die App
        container = CKContainer(identifier: "iCloud.\(Bundle.main.bundleIdentifier ?? "com.akeschmidi.PubRanker")")
        publicDatabase = container.publicCloudDatabase
    }
    
    /// Sendet anonymisierte Statistiken an CloudKit Public Database
    func sendAnalytics(totalQuizzes: Int, totalTeams: Int, totalRounds: Int, totalPoints: Int) {
        let record = CKRecord(recordType: "AppAnalytics")
        record["timestamp"] = Date() as CKRecordValue
        record["totalQuizzes"] = totalQuizzes as CKRecordValue
        record["totalTeams"] = totalTeams as CKRecordValue
        record["totalRounds"] = totalRounds as CKRecordValue
        record["totalPoints"] = totalPoints as CKRecordValue
        record["appVersion"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0" as CKRecordValue
        record["platform"] = "macOS" as CKRecordValue
        
        // Anonyme User-ID (nur für Aggregation, keine persönlichen Daten)
        record["anonymousUserId"] = getAnonymousUserId() as CKRecordValue
        
        publicDatabase.save(record) { record, error in
            if let error = error {
                print("⚠️ Analytics Error: \(error.localizedDescription)")
            } else {
                print("✅ Analytics gesendet")
            }
        }
    }
    
    /// Generiert eine anonyme User-ID (bleibt konstant pro Installation)
    private func getAnonymousUserId() -> String {
        let key = "com.akeschmidi.PubRanker.anonymousUserId"
        if let existingId = UserDefaults.standard.string(forKey: key) {
            return existingId
        }
        
        let newId = UUID().uuidString
        UserDefaults.standard.set(newId, forKey: key)
        return newId
    }
    
    /// Sendet ein Event (z.B. Quiz erstellt)
    func trackEvent(_ event: AnalyticsEvent) {
        let record = CKRecord(recordType: "AppEvents")
        record["eventType"] = event.rawValue as CKRecordValue
        record["timestamp"] = Date() as CKRecordValue
        record["anonymousUserId"] = getAnonymousUserId() as CKRecordValue
        record["appVersion"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0" as CKRecordValue
        
        publicDatabase.save(record) { record, error in
            if let error = error {
                print("⚠️ Event Tracking Error: \(error.localizedDescription)")
            }
        }
    }
}

enum AnalyticsEvent: String {
    case quizCreated = "quiz_created"
    case teamCreated = "team_created"
    case roundCreated = "round_created"
    case scoreEntered = "score_entered"
    case quizCompleted = "quiz_completed"
    case quizStarted = "quiz_started"
}







