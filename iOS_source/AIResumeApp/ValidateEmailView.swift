//
//  ValidateEmailView.swift
//  AIResumeApp
//
//  Created by Prasanna Deshmukh on 21/03/25.
//

import SwiftUI

struct ValidateEmailView: View {
    let email: String
    @State private var activationCode = ""
    @State private var errorMessage = ""
    @State private var isActivated = false
    @State private var isLoading = false

    var body: some View {
        VStack {
            Text("Activate Your Account")
                .font(.largeTitle)
                .bold()
                .padding()

            Text("Enter the activation code sent to \(email)")
                .multilineTextAlignment(.center)
                .padding()

            TextField("Activation Code", text: $activationCode)
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            if isLoading {
                ProgressView("Validating...")
                    .padding()
            }

            Button(action: {
                isLoading = true
                APIService.validateEmail(email: email, code: activationCode) { result in
                    DispatchQueue.main.async {
                        isLoading = false
                        switch result {
                        case .success:
                            isActivated = true  // ✅ Navigate to validation success screen
                        case .failure(let error):
                            errorMessage = "Error: \(error.localizedDescription)"
                        }
                    }
                }
            }) {
                Text("Validate Email")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
            }
            .disabled(isLoading)

            Text(errorMessage)
                .foregroundColor(.red)
                .padding()

            NavigationLink(destination: EmailValidationSuccessView(), isActive: $isActivated) { EmptyView() }
            // NavigationLink(destination: LoginView(), isActive: $isActivated) { EmptyView() }
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
