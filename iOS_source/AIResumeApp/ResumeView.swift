//
//  ResumeView.swift
//  AIResumeApp
//
//  Created by Prasanna Deshmukh on 20/03/25.
//

import SwiftUI

struct ResumeView: View {
    @State private var fullName = ""
    @State private var experience = ""
    @State private var skills = ""
    @State private var jobTitle = ""
    @State private var jobDescription = ""
    @State private var resumeText = "Your AI-generated resume will appear here."
    @State private var isResumeGenerated = false
    @State private var isLoading = false
    
    @EnvironmentObject var authViewModel: AuthViewModel  // Use shared auth state

    var body: some View {
        ZStack {
            VStack {
                if !authViewModel.isLoggedIn {
                    UnauthorizedView()
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // ✅ Input Fields
                            InputField(icon: "person.fill", placeholder: "Full Name", text: $fullName)
                            InputField(icon: "briefcase.fill", placeholder: "Experience", text: $experience)
                            InputField(icon: "hammer.fill", placeholder: "Skills", text: $skills)
                            InputField(icon: "doc.text.fill", placeholder: "Job Title", text: $jobTitle)
                            InputField(icon: "text.bubble.fill", placeholder: "Job Description", text: $jobDescription)

                            // ✅ Generate Resume Button
                            Button(action: generateResume) {
                                Text("Generate Resume")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(isLoading ? Color.gray : Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                    .shadow(radius: 3)
                                    .opacity(isLoading ? 0.5 : 1)
                            }
                            .disabled(isLoading)
                            .padding(.horizontal)

                            // ✅ Navigate to Generated Resume
                            NavigationLink(destination: GeneratedResumeView(resumeText: resumeText), isActive: $isResumeGenerated) { EmptyView() }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Resume Generator")
            .background(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.white]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all))

            // ✅ Full-Screen Loading Overlay
            if isLoading {
                ZStack {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()

                    Text("Generating your resume...")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                }
            }
        }
    }

    // ✅ Resume Generation Logic
    private func generateResume() {
        isLoading = true
        APIService.generateResume(fullName: fullName, experience: experience, skills: skills, jobTitle: jobTitle, jobDescription: jobDescription) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let resume):
                    resumeText = resume
                    isResumeGenerated = true
                case .failure(let error):
                    resumeText = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
}

// ✅ Reusable Input Field with Icons
struct InputField: View {
    var icon: String
    var placeholder: String
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: 30)
            
            TextField(placeholder, text: $text)
                .padding(12)
                .background(Color.white)
                .cornerRadius(8)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 1))
        .padding(.horizontal)
    }
}

// ✅ View for Unauthorized Users
struct UnauthorizedView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Access Restricted")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.red)

            Text("You must be logged in to generate a resume.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            NavigationLink(destination: LoginView()) {
                Text("Go to Login")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(radius: 3)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}
