//
//  LoginView.swift
//  AIResumeApp
//
//  Created by Prasanna Deshmukh on 21/03/25.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var message = ""
    @State private var navigateToSignup = false  // ✅ Track signup navigation
    @EnvironmentObject var authViewModel: AuthViewModel  // ✅ Shared authentication state

    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    Text("AI Resume")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .padding(.top, 40)

                    Text("Login")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                        .padding(.bottom, 10)
                }

                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: {
                    authViewModel.login(email: email, password: password) { success, errorMessage in
                        if success {
                            message = ""  // ✅ Clear any previous errors
                        } else {
                            message = errorMessage ?? "Invalid credentials. Please try again."  // ✅ Show error message
                        }
                    }
                }) {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding()
                }

                Text(message)
                    .foregroundColor(.red)
                    .padding()

                Button(action: {
                    navigateToSignup = true  // ✅ Navigate to SignupView
                }) {
                    Text("Don't have an account? Sign up")
                        .foregroundColor(.blue)
                        .padding()
                }

                NavigationLink(destination: SignupView(), isActive: $navigateToSignup) { EmptyView() }
            }
            .padding()
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.white]),
                               startPoint: .top,
                               endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
            )
        }
    }
}
