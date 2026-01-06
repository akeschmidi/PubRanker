//
//  LeaderboardImageGenerator.swift
//  PubRanker
//
//  Service for generating leaderboard images from SwiftUI views
//

import SwiftUI

#if os(macOS)
import AppKit
import PDFKit
typealias PlatformNativeImage = NSImage
#else
import UIKit
typealias PlatformNativeImage = UIImage
#endif

class LeaderboardImageGenerator {

    /// Generates a platform-specific image from the leaderboard view
    /// - Parameter quiz: The quiz to generate the leaderboard for
    /// - Returns: Platform-specific image (NSImage on macOS, UIImage on iOS)
    @MainActor
    static func generateImage(for quiz: Quiz) async -> PlatformNativeImage? {
        let view = LeaderboardImageView(quiz: quiz)
        let renderer = ImageRenderer(content: view)

        // Retina quality (2x scale)
        renderer.scale = 2.0
        renderer.isOpaque = true  // Avoid unnecessary alpha channel

        #if os(macOS)
        return renderer.nsImage
        #else
        return renderer.uiImage
        #endif
    }

    /// Generates PDF data from the leaderboard view
    /// - Parameter quiz: The quiz to generate the leaderboard for
    /// - Returns: PDF data suitable for email attachments
    @MainActor
    static func generatePDFData(for quiz: Quiz) async -> Data? {
        let view = LeaderboardImageView(quiz: quiz)
        let renderer = ImageRenderer(content: view)
        renderer.scale = 2.0
        renderer.isOpaque = true  // Avoid unnecessary alpha channel

        // Propose a large rect to ensure all content is captured
        let proposedSize = CGSize(width: 800, height: 10000)
        renderer.proposedSize = ProposedViewSize(proposedSize)

        #if os(macOS)
        guard let image = renderer.nsImage else {
            print("❌ Failed to generate leaderboard image")
            return nil
        }

        // Create PDF with PDFKit to add clickable link
        guard let pdfPage = PDFPage(image: image) else {
            print("❌ Failed to create PDF page from image")
            return nil
        }

        let pdfDocument = PDFDocument()
        pdfDocument.insert(pdfPage, at: 0)

        // Add clickable link annotation in footer area
        // The link area covers the bottom ~150 points of the page (footer area)
        let pageWidth = pdfPage.bounds(for: .mediaBox).width

        // Link area: centered in footer, covering QR code and text
        let linkRect = CGRect(
            x: (pageWidth - 500) / 2,  // Centered, 500pt wide
            y: 20,  // 20pt from bottom
            width: 500,
            height: 120  // Footer height
        )

        if let url = URL(string: "https://apps.apple.com/ch/app/pubranker/id6754255330") {
            let annotation = PDFAnnotation(bounds: linkRect, forType: .link, withProperties: nil)
            annotation.url = url
            annotation.backgroundColor = .clear
            pdfPage.addAnnotation(annotation)
        }

        guard let pdfData = pdfDocument.dataRepresentation() else {
            print("❌ Failed to get PDF data")
            return nil
        }

        print("✅ Generated leaderboard PDF: \(pdfData.count / 1024)KB, Size: \(image.size)")
        return pdfData

        #else
        guard let image = renderer.uiImage else {
            print("❌ Failed to generate leaderboard image")
            return nil
        }

        let format = UIGraphicsPDFRendererFormat()
        let pageRect = CGRect(origin: .zero, size: image.size)
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let pdfData = pdfRenderer.pdfData { context in
            context.beginPage()
            image.draw(in: pageRect)
        }

        print("✅ Generated leaderboard PDF: \(pdfData.count / 1024)KB, Size: \(image.size)")
        return pdfData
        #endif
    }

    /// Generates PNG data from the leaderboard view
    /// - Parameter quiz: The quiz to generate the leaderboard for
    /// - Returns: PNG image data suitable for email attachments
    @MainActor
    static func generatePNGData(for quiz: Quiz) async -> Data? {
        guard let image = await generateImage(for: quiz) else {
            print("❌ Failed to generate leaderboard image")
            return nil
        }

        #if os(macOS)
        // Convert NSImage to PNG data
        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let pngData = bitmap.representation(using: NSBitmapImageRep.FileType.png, properties: [:]) else {
            print("❌ Failed to convert NSImage to PNG data")
            return nil
        }

        print("✅ Generated leaderboard PNG: \(pngData.count / 1024)KB")
        return pngData

        #else
        // Convert UIImage to PNG data
        guard let pngData = image.pngData() else {
            print("❌ Failed to convert UIImage to PNG data")
            return nil
        }

        print("✅ Generated leaderboard PNG: \(pngData.count / 1024)KB")
        return pngData
        #endif
    }
}
