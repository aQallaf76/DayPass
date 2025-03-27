import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showingForgotPassword = false
    @State private var forgotPasswordEmail = ""
    @State private var showingPasswordResetConfirmation = false
    
    var body: some View {
        VStack(spacing: 20) {
            // App Logo
            Image(systemName: "beach.umbrella")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
                .padding(.bottom, 20)
            
            Text("Welcome Back")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Sign in to access your account")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom, 30)
            
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
                
                SecureField("Enter your password", text: $password)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
            }
            
            // Forgot Password Button
            Button(action: {
                showingForgotPassword = true
                forgotPasswordEmail = email
            }) {
                Text("Forgot Password?")
                    .foregroundColor(.blue)
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.vertical, 5)
            
            // Error Message
            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.subheadline)
                    .padding(.vertical, 5)
            }
            
            // Sign In Button
            Button(action: {
                authViewModel.signIn(email: email, password: password)
            }) {
                if authViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Sign In")
                        .fontWeight(.bold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(email.isEmpty || password.isEmpty || authViewModel.isLoading)
            .opacity((email.isEmpty || password.isEmpty || authViewModel.isLoading) ? 0.6 : 1)
            
            HStack {
                Text("Don't have an account?")
                    .foregroundColor(.secondary)
                
                NavigationLink(destination: SignUpView()) {
                    Text("Sign Up")
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
            }
            .padding(.top, 20)
        }
        .padding()
        .navigationBarHidden(true)
        .sheet(isPresented: $showingForgotPassword) {
            forgotPasswordView
        }
        .alert(isPresented: $showingPasswordResetConfirmation) {
            Alert(
                title: Text("Password Reset Email Sent"),
                message: Text("Check your email for instructions to reset your password."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    var forgotPasswordView: some View {
        VStack(spacing: 20) {
            Text("Reset Password")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 30)
            
            Text("Enter your email address and we'll send you instructions to reset your password.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            TextField("Email", text: $forgotPasswordEmail)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
            
            Button(action: {
                authViewModel.resetPassword(email: forgotPasswordEmail) { success in
                    if success {
                        showingForgotPassword = false
                        showingPasswordResetConfirmation = true
                    }
                }
            }) {
                if authViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Send Reset Link")
                        .fontWeight(.bold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
            .disabled(forgotPasswordEmail.isEmpty || authViewModel.isLoading)
            .opacity((forgotPasswordEmail.isEmpty || authViewModel.isLoading) ? 0.6 : 1)
            
            Button(action: {
                showingForgotPassword = false
            }) {
                Text("Cancel")
                    .foregroundColor(.secondary)
            }
            .padding(.top, 10)
            
            Spacer()
        }
        .padding()
    }
}
