//
//  EmailValidationSuccessView.swift
//  AIResumeApp
//
//  Created by Prasanna Deshmukh on 21/03/25.
//

import SwiftUI

struct EmailValidationSuccessView: View {
    @State private var navigateToLogin = false
    @State private var opacity: Double = 0.0
    @State private var scale: CGFloat = 0.5

    var body: some View {
        VStack {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.green)
                .scaleEffect(scale)  // ✅ Scale animation
                .padding()
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: scale)

            Text("Email Verified Successfully!")
                .font(.title)
                .fontWeight(.bold)
                .opacity(opacity)  // ✅ Fade-in animation
                .padding()
                .animation(.easeIn(duration: 1.0), value: opacity)

            Text("Redirecting to login...")
                .foregroundColor(.gray)
                .padding(.bottom, 20)
                .opacity(opacity)
                .animation(.easeIn(duration: 1.5), value: opacity)

            if navigateToLogin {
                NavigationLink(destination: LoginView().transition(.opacity), isActive: $navigateToLogin) { EmptyView() }
            }
        }
        .onAppear {
            scale = 1.0  // ✅ Animate checkmark scale
            opacity = 1.0  // ✅ Fade-in text
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                withAnimation(.easeOut(duration: 1.0)) {  // ✅ Fade out before transition
                    opacity = 0.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    navigateToLogin = true
                }
            }
        }
    }
}
