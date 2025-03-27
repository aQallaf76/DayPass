import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var passwordsMatch = true
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Create an Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Join our community of day pass enthusiasts")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 20)
                
                // First Name Field
                VStack(alignment: .leading) {
                    Text("First Name")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    TextField("Enter your first name", text: $firstName)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
                
                // Last Name Field
                VStack(alignment: .leading) {
                    Text("Last Name")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    TextField("Enter your last name", text: $lastName)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
                
                // Email Field
                VStack(alignment: .leading) {
                    Text("Email")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    TextField("Enter your email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
                
                // Password Field
                VStack(alignment: .leading) {
                    Text("Password")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    SecureField("Create a password", text: $password)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    
                    Text("Password must be at least 8 characters")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Confirm Password Field
                VStack(alignment: .leading) {
                    Text("Confirm Password")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    SecureField("Confirm your password", text: $confirmPassword)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .onChange(of: confirmPassword) { _ in
                            passwordsMatch = password == confirmPassword
                        }
                    
                    if !passwordsMatch && !confirmPassword.isEmpty {
                        Text("Passwords do not match")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                // Error Message
                if let errorMessage = authViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .padding(.vertical, 5)
                }
                
                // Sign Up Button
                Button(action: {
                    if isFormValid() {
                        authViewModel.signUp(
                            email: email,
                            password: password,
                            firstName: firstName,
                            lastName: lastName
                        )
                    }
                }) {
                    if authViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Create Account")
                            .fontWeight(.bold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isFormValid() ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(!isFormValid() || authViewModel.isLoading)
                
                HStack {
                    Text("Already have an account?")
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Sign In")
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.top, 20)
            }
            .padding()
        }
        .navigationBarTitle("Sign Up", displayMode: .inline)
    }
    
    private func isFormValid() -> Bool {
        return !firstName.isEmpty &&
               !lastName.isEmpty &&
               !email.isEmpty &&
               !password.isEmpty &&
               password == confirmPassword &&
               password.count >= 8
    }
}
