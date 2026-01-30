//
//  Round.swift
//  PubRanker
//
//  Created on 20.10.2025
//

import Foundation
import SwiftData

@Model
final class Round {
    var id: UUID = UUID()
    var name: String = ""
    var maxPoints: Int? = nil
    var orderIndex: Int = 0
    var isCompleted: Bool = false
    var createdAt: Date = Date()

    /// Optionales Bild für die Runde (z.B. Kategorie-Symbol)
    @Attribute(.externalStorage)
    var imageData: Data? = nil

    @Relationship(deleteRule: .nullify, inverse: \Quiz.rounds)
    var quiz: Quiz?

    init(name: String, maxPoints: Int? = nil, orderIndex: Int = 0, imageData: Data? = nil) {
        self.id = UUID()
        self.name = name
        self.maxPoints = maxPoints
        self.orderIndex = orderIndex
        self.isCompleted = false
        self.createdAt = Date()
        self.imageData = imageData
    }
}
