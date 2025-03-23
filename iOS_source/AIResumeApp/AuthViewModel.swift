//
//  AuthViewModel.swift
//  AIResumeApp
//
//  Created by Prasanna Deshmukh on 21/03/25.
//

import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = UserDefaults.standard.string(forKey: "jwtToken") != nil
    @Published var hasLoggedOut = false
    @Published var shouldStayOnScreen = true // ✅ Added to control navigation
    @Published var isSessionExpired = false // ✅ Track session expiration
    private var inactivityTimer: Timer?

    init() {
        checkInactivityLogout()
        startInactivityTimer()
    }

    func login(email: String, password: String, completion: ((Bool, String?) -> Void)? = nil) {
        APIService.login(email: email, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let token):
                    UserDefaults.standard.set(token, forKey: "jwtToken")
                    UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "lastActivity") // ✅ Track login time
                    self.isLoggedIn = true
                    self.hasLoggedOut = false
                    self.isSessionExpired = false // ✅ Reset session expiration flag
                    self.startInactivityTimer()
                    completion?(true, nil)
                case .failure(let error):
                    self.isLoggedIn = false
                    completion?(false, error.localizedDescription)
                }
            }
        }
    }

    func logout(sessionExpired: Bool = false) {
        UserDefaults.standard.removeObject(forKey: "jwtToken")
        UserDefaults.standard.removeObject(forKey: "lastActivity")
        self.isLoggedIn = false
        self.hasLoggedOut = true
        self.isSessionExpired = sessionExpired // ✅ Track if the session expired
        inactivityTimer?.invalidate()
    }

    private func startInactivityTimer() {
        inactivityTimer?.invalidate()
        inactivityTimer = Timer.scheduledTimer(withTimeInterval: 1800, repeats: false) { _ in
            self.logout(sessionExpired: true) // ✅ Force logout due to inactivity
        }
    }

    func resetInactivityTimer() {
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "lastActivity")
        startInactivityTimer()
    }

    private func checkInactivityLogout() {
        if let lastActivity = UserDefaults.standard.value(forKey: "lastActivity") as? TimeInterval {
            let elapsed = Date().timeIntervalSince1970 - lastActivity
            if elapsed > 1800 {
                logout(sessionExpired: true) // ✅ Require re-login
            }
        }
    }

    func performAction(requiresAuth: Bool, action: @escaping () -> Void) {
        if requiresAuth && isSessionExpired {
            // ✅ Show login prompt instead of performing the action
            print("Session expired. Please log in again.")
        } else {
            action()
        }
    }
}
