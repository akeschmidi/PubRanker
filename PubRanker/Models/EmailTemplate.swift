//
//  EmailTemplate.swift
//  PubRanker
//
//  Created on 23.11.2025
//

import Foundation

struct EmailTemplate: Identifiable {
    let id = UUID()
    let nameKey: String
    let subjectKey: String
    let bodyKey: String
    let icon: String
    
    var name: String {
        NSLocalizedString(nameKey, comment: "")
    }
    
    var subject: String {
        NSLocalizedString(subjectKey, comment: "")
    }
    
    var body: String {
        NSLocalizedString(bodyKey, comment: "")
    }
    
    static let templates = [
        EmailTemplate(
            nameKey: "email.template.invitation.name",
            subjectKey: "email.template.invitation.subject",
            bodyKey: "email.template.invitation.body",
            icon: "envelope.fill"
        ),
        EmailTemplate(
            nameKey: "email.template.reminder.name",
            subjectKey: "email.template.reminder.subject",
            bodyKey: "email.template.reminder.body",
            icon: "bell.fill"
        ),
        EmailTemplate(
            nameKey: "email.template.results.name",
            subjectKey: "email.template.results.subject",
            bodyKey: "email.template.results.body",
            icon: "trophy.fill"
        ),
        EmailTemplate(
            nameKey: "email.template.thankyou.name",
            subjectKey: "email.template.thankyou.subject",
            bodyKey: "email.template.thankyou.body",
            icon: "heart.fill"
        ),
        EmailTemplate(
            nameKey: "email.template.scheduleChange.name",
            subjectKey: "email.template.scheduleChange.subject",
            bodyKey: "email.template.scheduleChange.body",
            icon: "calendar.badge.exclamationmark"
        )
    ]
}

