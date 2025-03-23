import SwiftUI

struct SignupView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""
    @State private var navigateToActivation = false
    @State private var isLoading = false
    @State private var userExists = false
    @State private var isCheckingUserExists = false  // ✅ New state for loading indicator

    var passwordRequirements: [String] {
        var unmetRequirements = [String]()

        if password.isEmpty {
            unmetRequirements.append("Password is required")
        }
        if password.count > 20 {
            unmetRequirements.append("Maximum 20 characters allowed")
        }
        if password.rangeOfCharacter(from: CharacterSet.letters) == nil {
            unmetRequirements.append("One letter required")
        }
        if password.rangeOfCharacter(from: CharacterSet.decimalDigits) == nil {
            unmetRequirements.append("Must contain at least one number")
        }

        return unmetRequirements
    }

    var areAllFieldsFilled: Bool {
        return !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Text("Sign Up")
                        .font(.largeTitle)
                        .bold()
                        .padding()

                    VStack(alignment: .leading) {
                        Text("Email *")
                            .font(.subheadline)
                        TextField("Enter your email", text: $email, onEditingChanged: { isEditing in
                            if !isEditing {
                                checkUserExists()
                            }
                        })
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        if isCheckingUserExists {
                            ProgressView("Checking...")  // ✅ Small loading indicator
                                .font(.footnote)
                                .padding(.top, 5)
                        }

                        if userExists {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                Text("User already exists")
                                    .foregroundColor(.red)
                                    .font(.footnote) // ✅ Smaller font for better UI
                            }
                            .padding(.top, 5)
                        }

                        if !email.isEmpty && !isValidEmail(email) {
                            Text("Invalid email format.")
                                .foregroundColor(.red)
                        }
                    }
                    .padding()

                    VStack(alignment: .leading) {
                        Text("Password *")
                            .font(.subheadline)
                            .foregroundColor(.red)
                        SecureField("Enter your password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding()

                    VStack(alignment: .leading) {
                        Text("Confirm Password *")
                            .font(.subheadline)
                            .foregroundColor(.red)
                        SecureField("Re-enter your password", text: $confirmPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding()

                    if !passwordRequirements.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Password Requirements:")
                                .font(.headline)
                                .padding(.top)

                            ForEach(passwordRequirements, id: \.self) { requirement in
                                HStack {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                    Text(requirement)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    if !confirmPassword.isEmpty && confirmPassword != password {
                        Text("Passwords do not match.")
                            .foregroundColor(.red)
                            .bold()
                            .padding(.bottom)
                    }

                    if isLoading {
                        ProgressView("Registering...")
                            .padding()
                    }

                    Button(action: {
                        guard areAllFieldsFilled, isValidEmail(email), passwordRequirements.isEmpty, password == confirmPassword, !userExists else {
                            errorMessage = "Please fill all required fields and ensure password meets requirements."
                            return
                        }

                        isLoading = true
                        print("🔹 Sending Signup Request...")

                        APIService.register(email: email, password: password) { result in
                            DispatchQueue.main.async {
                                isLoading = false
                                switch result {
                                case .success:
                                    print("✅ Signup successful, navigating to activation screen.")
                                    navigateToActivation = true
                                case .failure(let error):
                                    print("❌ Signup failed:", error.localizedDescription)
                                    errorMessage = "Error: \(error.localizedDescription)"
                                }
                            }
                        }
                    }) {
                        Text("Sign Up")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(areAllFieldsFilled && isValidEmail(email) && passwordRequirements.isEmpty && password == confirmPassword && !userExists ? Color.green : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding()
                    }
                    .disabled(isLoading || !areAllFieldsFilled || !isValidEmail(email) || !passwordRequirements.isEmpty || password != confirmPassword || userExists)

                    Text(errorMessage)
                        .foregroundColor(.red)
                        .bold()
                        .padding()

                    NavigationLink(destination: ValidateEmailView(email: email), isActive: $navigateToActivation) { EmptyView() }
                }
                .padding()
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.white]),
                                   startPoint: .top,
                                   endPoint: .bottom)
                        .edgesIgnoringSafeArea(.all)
                )
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }

    private func checkUserExists() {
        guard !email.isEmpty, isValidEmail(email) else { return }

        isCheckingUserExists = true // ✅ Show loading indicator
        print("🔍 Checking if user exists: \(email)")

        APIService.checkUserExists(email: email) { exists in
            DispatchQueue.main.async {
                self.userExists = exists
                self.isCheckingUserExists = false // ✅ Hide loading indicator
                print("✅ User exists status: \(exists)")
            }
        }
    }
}
