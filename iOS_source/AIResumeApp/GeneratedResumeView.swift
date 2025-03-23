//
//  GeneratedResumeView.swift
//  AIResumeApp
//
//  Created by Prasanna Deshmukh on 21/03/25.
//

import SwiftUI

struct GeneratedResumeView: View {
    let resumeText: String  // Pass the generated resume text
    @State private var pdfURL: URL?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Generated Resume")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 10)

                Text(resumeText)
                    .font(.body)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                
                Button(action: {
                    pdfURL = PDFGenerator.createPDF(from: resumeText, filename: "Resume")
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
        .navigationTitle("Resume Preview")
    }
}
