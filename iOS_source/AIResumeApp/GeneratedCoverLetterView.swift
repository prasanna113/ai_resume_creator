//
//  GeneratedCoverLetterView.swift
//  AIResumeApp
//
//  Created by Prasanna Deshmukh on 21/03/25.
//

import SwiftUI

struct GeneratedCoverLetterView: View {
    let coverLetterText: String  // Pass the generated cover letter text
    @State private var pdfURL: URL?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Generated Cover Letter")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 10)

                Text(coverLetterText)
                    .font(.body)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                
                Button(action: {
                    pdfURL = PDFGenerator.createPDF(from: coverLetterText, filename: "CoverLetter")
                }) {
                    Text("Download PDF")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding()
                }

                if let url = pdfURL {
                    ShareLink(item: url) {
                        Text("Share PDF")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding()
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Cover Letter Preview")
    }
}
