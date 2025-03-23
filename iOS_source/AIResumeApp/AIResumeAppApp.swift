//
//  AIResumeAppApp.swift
//  AIResumeApp
//
//  Created by Prasanna Deshmukh on 20/03/25.
//

import SwiftUI

@main
struct AIResumeApp: App {
    @StateObject var authViewModel = AuthViewModel()  // Shared state

    var body: some Scene {
        WindowGroup {
            if authViewModel.isLoggedIn {
                HomeView()
                    .environmentObject(authViewModel)  // Pass auth state to all views
            } else {
                LoginView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
