//
//  LoginView.swift
//  AIResumeApp
//
//  Created by Prasanna Deshmukh on 20/03/25.
//

import SwiftUI

struct ContentView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var message = ""
    @EnvironmentObject var authViewModel: AuthViewModel  // ✅ Use shared auth state

    var body: some View {
        VStack {
            Text("Login")
                .font(.largeTitle)
                .bold()
                .padding()
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                authViewModel.login(email: email, password: password)
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
        }
        .padding()
    }
}
