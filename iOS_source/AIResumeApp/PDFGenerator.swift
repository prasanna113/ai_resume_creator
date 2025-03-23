//
//  PDFGenerator.swift
//  AIResumeApp
//
//  Created by Prasanna Deshmukh on 21/03/25.
//

import UIKit
import PDFKit

struct PDFGenerator {
    static func createPDF(from text: String, filename: String) -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "AIResumeApp",
            kCGPDFContextAuthor: "AI Generator"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(filename).pdf")

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), format: format)

        do {
            try renderer.writePDF(to: fileURL, withActions: { context in
                context.beginPage()
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .left

                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 14),
                    .paragraphStyle: paragraphStyle
                ]

                let attributedText = NSAttributedString(string: text, attributes: attributes)
                attributedText.draw(in: CGRect(x: 20, y: 20, width: pageWidth - 40, height: pageHeight - 40))
            })
            return fileURL
        } catch {
            print("Failed to create PDF: \(error)")
            return nil
        }
    }
}
