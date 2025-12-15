//
//  EmailService.swift
//  PubRanker
//
//  Created on 23.11.2025
//

import Foundation
import AppKit

/// Service zum Versenden von E-Mails an Teams
class EmailService {
    
    /// Öffnet die Mail-App mit einer E-Mail an alle Teams
    /// - Parameters:
    ///   - teams: Array von Teams, an die die E-Mail gesendet werden soll
    ///   - subject: Betreff der E-Mail (optional)
    ///   - body: Inhalt der E-Mail (optional)
    static func sendEmail(to teams: [Team], subject: String = "", body: String = "") {
        // E-Mail-Adressen trimmen und leere/nur-Whitespace Adressen filtern
        let emailAddresses = teams
            .map { $0.email.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        guard !emailAddresses.isEmpty else {
            showNoEmailAddressesAlert()
            return
        }
        
        let recipients = emailAddresses.joined(separator: ",")
        openMailApp(recipients: recipients, subject: subject, body: body)
    }
    
    /// Öffnet die Mail-App mit einer E-Mail an alle Teams eines Quiz
    /// - Parameters:
    ///   - quiz: Das Quiz, dessen Teams die E-Mail erhalten sollen
    ///   - subject: Betreff der E-Mail (optional)
    ///   - body: Inhalt der E-Mail (optional)
    static func sendEmailToQuizTeams(quiz: Quiz, subject: String = "", body: String = "") {
        let teams = quiz.safeTeams
        sendEmail(to: teams, subject: subject, body: body)
    }
    
    /// Öffnet die Mail-App mit einer E-Mail an alle Teams
    /// - Parameters:
    ///   - allTeams: Array aller Teams
    ///   - subject: Betreff der E-Mail (optional)
    ///   - body: Inhalt der E-Mail (optional)
    static func sendEmailToAllTeams(allTeams: [Team], subject: String = "", body: String = "") {
        sendEmail(to: allTeams, subject: subject, body: body)
    }
    
    /// Öffnet die Mail-App mit den angegebenen Parametern
    /// - Parameters:
    ///   - recipients: Komma-getrennte Liste von E-Mail-Adressen (für BCC)
    ///   - subject: Betreff der E-Mail
    ///   - body: Inhalt der E-Mail
    private static func openMailApp(recipients: String, subject: String, body: String) {
        // Logging für Debugging
        print("📧 E-Mail wird gesendet an \(recipients.components(separatedBy: ",").count) Empfänger")
        print("📧 Empfänger: \(recipients)")
        
        // Manuelle URL-Erstellung, da URLComponents Kommas in BCC encodiert,
        // was manche Mail-Clients nicht verstehen
        var queryParts: [String] = []
        
        // BCC - Kommas dürfen NICHT encodiert werden für mailto
        if !recipients.isEmpty {
            // E-Mail-Adressen einzeln URL-encodieren, aber Kommas beibehalten
            let encodedRecipients = recipients
                .components(separatedBy: ",")
                .compactMap { email -> String? in
                    let trimmed = email.trimmingCharacters(in: .whitespaces)
                    return trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                }
                .joined(separator: ",")
            queryParts.append("bcc=\(encodedRecipients)")
        }
        
        // Subject und Body normal encodieren
        if !subject.isEmpty, let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            queryParts.append("subject=\(encodedSubject)")
        }
        
        if !body.isEmpty, let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            queryParts.append("body=\(encodedBody)")
        }
        
        let urlString = "mailto:?\(queryParts.joined(separator: "&"))"
        
        guard let url = URL(string: urlString) else {
            print("❌ Fehler: Konnte mailto-URL nicht erstellen")
            print("❌ URL-String war: \(urlString)")
            return
        }
        
        print("📧 Öffne URL: \(url.absoluteString.prefix(200))...")
        NSWorkspace.shared.open(url)
    }
    
    /// Zeigt eine Warnung an, wenn keine E-Mail-Adressen vorhanden sind
    private static func showNoEmailAddressesAlert() {
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("email.noAddresses.title", comment: "No email addresses title")
        alert.informativeText = NSLocalizedString("email.noAddresses.message", comment: "No email addresses message")
        alert.alertStyle = .warning
        alert.addButton(withTitle: NSLocalizedString("alert.ok", comment: "OK"))
        alert.runModal()
    }
    
    /// Erstellt einen Standard-Betreff für ein Quiz
    /// - Parameter quiz: Das Quiz
    /// - Returns: Betreff-String
    static func defaultSubject(for quiz: Quiz) -> String {
        return String(format: NSLocalizedString("email.quiz.subject", comment: "Quiz email subject"), quiz.name)
    }
    
    /// Erstellt einen Standard-E-Mail-Text für ein Quiz
    /// - Parameter quiz: Das Quiz
    /// - Returns: Body-String
    static func defaultBody(for quiz: Quiz) -> String {
        var body = String(format: NSLocalizedString("email.quiz.body.intro", comment: "Quiz email body intro"), quiz.name)
        
        if !quiz.venue.isEmpty {
            body += "\n\n" + String(format: NSLocalizedString("email.quiz.body.venue", comment: "Quiz email body venue"), quiz.venue)
        }
        
        body += "\n" + String(format: NSLocalizedString("email.quiz.body.date", comment: "Quiz email body date"), quiz.date.formatted(date: .long, time: .shortened))
        
        if !quiz.safeTeams.isEmpty {
            body += "\n" + String(format: NSLocalizedString("email.quiz.body.teams", comment: "Quiz email body teams"), quiz.safeTeams.count)
        }
        
        return body
    }
}

