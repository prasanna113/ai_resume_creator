//
//  CoverLetterView.swift
//  AIResumeApp
//
//  Created by Prasanna Deshmukh on 21/03/25.
//

import SwiftUI

struct CoverLetterView: View {
    @State private var fullName = ""
    @State private var experience = ""
    @State private var jobTitle = ""
    @State private var jobDescription = ""
    @State private var coverLetterText = "Your AI-generated cover letter will appear here."
    @State private var isCoverLetterGenerated = false
    @State private var isLoading = false
    
    @EnvironmentObject var authViewModel: AuthViewModel  // ✅ Shared authentication state

    var body: some View {
        NavigationStack {
            VStack {
                if !authViewModel.isLoggedIn {
                    UnauthorizedView()  // ✅ Restrict access for unauthorized users
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // ✅ Input Fields
                            InputField(icon: "person.fill", placeholder: "Full Name", text: $fullName)
                            InputField(icon: "briefcase.fill", placeholder: "Experience", text: $experience)
                            InputField(icon: "doc.text.fill", placeholder: "Job Title", text: $jobTitle)
                            InputField(icon: "text.bubble.fill", placeholder: "Job Description", text: $jobDescription)

                            // ✅ Generate Cover Letter Button
                            Button(action: generateCoverLetter) {
                                if isLoading {
                                    ProgressView()
                                } else {
                                    Text("Generate Cover Letter")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                        .shadow(radius: 3)
                                }
                            }
                            .disabled(isLoading)
                            .padding(.horizontal)

                            // ✅ Navigate to Generated Cover Letter
                            NavigationLink(destination: GeneratedCoverLetterView(coverLetterText: coverLetterText), isActive: $isCoverLetterGenerated) { EmptyView() }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Cover Letter Generator")
            .navigationBarBackButtonHidden(false) // ✅ System handles back button with correct title
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.white]),
                               startPoint: .top,
                               endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
            )
            .overlay(
                Group {
                    if isLoading {
                        ZStack {
                            Color.black.opacity(0.5)
                                .ignoresSafeArea()

                            Text("Generating your cover letter...")
                                .font(.title2) // ✅ Increased font size
                                .fontWeight(.semibold)
                                .foregroundColor(Color.white.opacity(0.9)) // ✅ Enhanced visibility
                                .padding()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center) // ✅ Ensures full-screen centering
                    }
                }
            )
        }
    }

    // ✅ Cover Letter Generation Logic
    private func generateCoverLetter() {
        isLoading = true
        APIService.generateCoverLetter(fullName: fullName, experience: experience, jobTitle: jobTitle, jobDescription: jobDescription) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let coverLetter):
                    coverLetterText = coverLetter
                    isCoverLetterGenerated = true
                case .failure(let error):
                    coverLetterText = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
}
