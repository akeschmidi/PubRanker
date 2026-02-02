//
//  EmailService.swift
//  PubRanker
//
//  Created on 23.11.2025
//  Updated for Universal App (macOS + iPadOS) - Version 3.0
//

import Foundation
import SwiftUI
import os.log

#if os(macOS)
import AppKit
#else
import UIKit
import MessageUI
#endif

/// Service zum Versenden von E-Mails an Teams
class EmailService {
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "PubRanker", category: "Email")
    
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
        
        #if os(macOS)
        // Always use NSSharingService on macOS for bodies > 200 chars
        // mailto: URLs have length limits (~2000 chars total), and URL encoding
        // of special characters (umlauts, &, newlines) expands significantly
        if body.count > 200 {
            sendEmailWithLongBody(recipients: emailAddresses, subject: subject, body: body)
            return
        }
        #endif
        
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
        logger.info("E-Mail wird gesendet an \(recipients.components(separatedBy: ",").count) Empfänger")
        logger.debug("Empfänger: \(recipients)")
        
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
            logger.error("Konnte mailto-URL nicht erstellen")
            logger.debug("URL-String war: \(urlString)")
            return
        }

        logger.debug("Öffne URL: \(url.absoluteString.prefix(200))...")
        
        #if os(macOS)
        NSWorkspace.shared.open(url)
        #else
        UIApplication.shared.open(url)
        #endif
    }
    
    /// Zeigt eine Warnung an, wenn keine E-Mail-Adressen vorhanden sind
    private static func showNoEmailAddressesAlert() {
        #if os(macOS)
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("email.noAddresses.title", comment: "No email addresses title")
        alert.informativeText = NSLocalizedString("email.noAddresses.message", comment: "No email addresses message")
        alert.alertStyle = .warning
        alert.addButton(withTitle: NSLocalizedString("alert.ok", comment: "OK"))
        alert.runModal()
        #else
        // Auf iOS wird das Alert über SwiftUI gehandhabt
        // Der Aufrufer sollte den Fehlerfall behandeln
        logger.warning("Keine E-Mail-Adressen vorhanden")
        #endif
    }
    
    /// Prüft, ob E-Mail senden möglich ist
    static var canSendEmail: Bool {
        #if os(macOS)
        return true // macOS kann immer mailto: URLs öffnen
        #else
        // Prüfe ob Mail-App verfügbar ist
        if let mailURL = URL(string: "mailto:test@test.com") {
            return UIApplication.shared.canOpenURL(mailURL)
        }
        return false
        #endif
    }

    #if os(macOS)
    /// Sendet eine E-Mail mit Bild-Anhang über NSSharingService
    /// - Parameters:
    ///   - teams: Array von Teams, an die die E-Mail gesendet werden soll
    ///   - subject: Betreff der E-Mail
    ///   - body: Inhalt der E-Mail
    ///   - image: Das anzuhängende Bild
    ///   - imageName: Dateiname für den Anhang (Standard: "Rangliste.png")
    ///   - completion: Callback mit Erfolg/Fehler Status
    static func sendEmailWithAttachment(
        to teams: [Team],
        subject: String,
        body: String,
        image: NSImage,
        imageName: String = "Rangliste.png",
        completion: @escaping (Bool) -> Void
    ) {
        // E-Mail-Adressen der Teams sammeln (BCC)
        let recipients = teams
            .map { $0.email.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard !recipients.isEmpty else {
            logger.warning("Keine E-Mail-Adressen vorhanden")
            completion(false)
            return
        }

        // Bild in PNG-Daten konvertieren
        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let pngData = bitmap.representation(using: .png, properties: [:]) else {
            logger.error("Konnte Bild nicht in PNG konvertieren")
            completion(false)
            return
        }

        // Temporäre Datei für Anhang erstellen
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(imageName)

        do {
            try pngData.write(to: tempURL)
            logger.debug("Temporäre Datei erstellt: \(tempURL.path)")
        } catch {
            logger.error("Fehler beim Schreiben der temporären Datei: \(error)")
            completion(false)
            return
        }

        // NSSharingService für E-Mail verwenden
        guard let sharingService = NSSharingService(named: .composeEmail) else {
            logger.error("E-Mail Sharing Service nicht verfügbar")
            completion(false)
            return
        }

        // E-Mail-Text und Anhang vorbereiten
        let messageText = "\(subject)\n\n\(body)"
        let items: [Any] = [messageText, tempURL]

        // Empfänger setzen (BCC für Datenschutz)
        sharingService.recipients = recipients
        sharingService.subject = subject

        // Prüfen ob Service verfügbar ist
        guard sharingService.canPerform(withItems: items) else {
            logger.error("E-Mail Service kann nicht ausgeführt werden")
            completion(false)
            return
        }

        logger.info("Sende E-Mail mit Anhang an \(recipients.count) Empfänger (BCC)")

        // E-Mail-Composer öffnen
        sharingService.perform(withItems: items)
        completion(true)

        // Temporäre Datei nach kurzer Verzögerung löschen
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            try? FileManager.default.removeItem(at: tempURL)
            Self.logger.debug("Temporäre Datei gelöscht")
        }
    }
    
    /// Sendet eine E-Mail mit langem Text (ohne Anhang) über NSSharingService
    /// - Parameters:
    ///   - recipients: E-Mail-Adressen (BCC)
    ///   - subject: Betreff
    ///   - body: Text
    ///   - completion: Optionaler Callback
    static func sendEmailWithLongBody(
        recipients: [String],
        subject: String,
        body: String,
        completion: ((Bool) -> Void)? = nil
    ) {
        guard !recipients.isEmpty else {
            logger.warning("Keine E-Mail-Adressen vorhanden")
            completion?(false)
            return
        }
        guard let sharingService = NSSharingService(named: .composeEmail) else {
            logger.error("E-Mail Sharing Service nicht verfügbar")
            completion?(false)
            return
        }
        sharingService.recipients = recipients
        sharingService.subject = subject
        let items: [Any] = [body]
        if sharingService.canPerform(withItems: items) {
            sharingService.perform(withItems: items)
            completion?(true)
        } else {
            logger.error("E-Mail Service kann nicht ausgeführt werden")
            completion?(false)
        }
    }
    #endif
    
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

// MARK: - iOS Mail Composer View

#if os(iOS)
/// SwiftUI Wrapper für MFMailComposeViewController
struct MailComposeView: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss

    let recipients: [String]
    let subject: String
    let body: String
    var attachmentData: Data?
    var attachmentMimeType: String?
    var attachmentFileName: String?
    var onResult: ((Result<MFMailComposeResult, Error>) -> Void)?

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = context.coordinator
        composer.setBccRecipients(recipients)
        composer.setSubject(subject)
        composer.setMessageBody(body, isHTML: false)

        // Anhang hinzufügen, falls vorhanden
        if let data = attachmentData,
           let mimeType = attachmentMimeType,
           let fileName = attachmentFileName {
            composer.addAttachmentData(data, mimeType: mimeType, fileName: fileName)
            print("✅ Anhang hinzugefügt: \(fileName) (\(data.count / 2024)KB)")
        }

        return composer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: MailComposeView
        
        init(_ parent: MailComposeView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            if let error = error {
                parent.onResult?(.failure(error))
            } else {
                parent.onResult?(.success(result))
            }
            parent.dismiss()
        }
    }
}

/// Prüft ob MFMailComposeViewController verfügbar ist
extension EmailService {
    static var canUseMailComposer: Bool {
        MFMailComposeViewController.canSendMail()
    }
}
#endif

