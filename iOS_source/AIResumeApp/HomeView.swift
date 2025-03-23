//
//  HomeView.swift
//  AIResumeApp
//
//  Created by Prasanna Deshmukh on 21/03/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel  // Manage authentication state

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Welcome!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 30)

                Text("What would you like to generate?")
                    .font(.headline)
                    .foregroundColor(.secondary)

                // ✅ Resume Generator Button
                NavigationLink(destination: ResumeView()) {
                    SelectionButton(title: "Resume Generator", icon: "doc.text.fill", color: .green)
                }

                // ✅ Cover Letter Generator Button
                NavigationLink(destination: CoverLetterView()) {
                    SelectionButton(title: "Cover Letter Generator", icon: "envelope.fill", color: .blue)
                }

                Spacer()

                // ✅ Logout Button (Placeholder)
                Button(action: {
                    authViewModel.logout()
                    print("Logout tapped!")  // Placeholder for now
                }) {
                    Text("Logout")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(radius: 3)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .padding()
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.white]),
                               startPoint: .top,
                               endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
            )
            .navigationTitle("Dashboard")
        }
    }
}

// ✅ Reusable Selection Button
struct SelectionButton: View {
    var title: String
    var icon: String
    var color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white)
                .font(.title)
                .frame(width: 40)

            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.leading, 10)

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(color)
        .cornerRadius(12)
        .shadow(radius: 3)
        .padding(.horizontal)
    }
}
