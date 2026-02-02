//
//  ServiceError.swift
//  PubRanker
//
//  Zentralisierte Fehlertypen für alle Service-Operationen
//

import Foundation

/// Fehlertypen für Service-Operationen
enum ServiceError: LocalizedError {
    case saveFailed(underlying: Error)
    case deleteFailed(underlying: Error)
    case notFound(entityType: String, id: UUID?)
    case invalidInput(reason: String)
    case alreadyExists(entityType: String, name: String)
    case operationFailed(reason: String)
    case validationFailed(field: String, reason: String)

    var errorDescription: String? {
        switch self {
        case .saveFailed(let error):
            return "Speichern fehlgeschlagen: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Löschen fehlgeschlagen: \(error.localizedDescription)"
        case .notFound(let entityType, let id):
            if let id = id {
                return "\(entityType) mit ID \(id) nicht gefunden"
            }
            return "\(entityType) nicht gefunden"
        case .invalidInput(let reason):
            return "Ungültige Eingabe: \(reason)"
        case .alreadyExists(let entityType, let name):
            return "\(entityType) '\(name)' existiert bereits"
        case .operationFailed(let reason):
            return "Operation fehlgeschlagen: \(reason)"
        case .validationFailed(let field, let reason):
            return "Validierung fehlgeschlagen für '\(field)': \(reason)"
        }
    }

    var failureReason: String? {
        switch self {
        case .saveFailed(let error):
            return error.localizedDescription
        case .deleteFailed(let error):
            return error.localizedDescription
        case .notFound, .invalidInput, .alreadyExists, .operationFailed, .validationFailed:
            return errorDescription
        }
    }
}
