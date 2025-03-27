//
//  SettingsView.swift
//  DayPass
//
//  Created by Abdullah Alqallaf on 3/19/25.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("emailNotificationsEnabled") private var emailNotificationsEnabled = true
    @AppStorage("locationServiceEnabled") private var locationServiceEnabled = true
    @AppStorage("currencyCode") private var currencyCode = "USD"
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    @State private var showingResetAlert = false
    
    var body: some View {
        Form {
            // Notifications
            Section(header: Text("Notifications")) {
                Toggle("Push Notifications", isOn: $notificationsEnabled)
                
                Toggle("Email Notifications", isOn: $emailNotificationsEnabled)
            }
            
            // Location Services
            Section(header: Text("Location")) {
                Toggle("Location Services", isOn: $locationServiceEnabled)
                
                if locationServiceEnabled {
                    NavigationLink("Nearby Search Radius") {
                        LocationRadiusSettingView()
                    }
                }
            }
            
            // Appearance
            Section(header: Text("Appearance")) {
                Toggle("Dark Mode", isOn: $darkModeEnabled)
            }
            
            // Currency
            Section(header: Text("Currency")) {
                Picker("Currency", selection: $currencyCode) {
                    Text("USD ($)").tag("USD")
                    Text("EUR (€)").tag("EUR")
                    Text("GBP (£)").tag("GBP")
                    Text("JPY (¥)").tag("JPY")
                    Text("AUD (A$)").tag("AUD")
                    Text("CAD (C$)").tag("CAD")
                }
            }
            
            // Account
            Section(header: Text("Account")) {
                NavigationLink("Change Password") {
                    ChangePasswordView()
                }
                
                NavigationLink("Privacy Settings") {
                    PrivacySettingsView()
                }
                
                Button(action: {
                    showingResetAlert = true
                }) {
                    Text("Reset App Settings")
                        .foregroundColor(.red)
                }
            }
            
            // About
            Section(header: Text("About")) {
                NavigationLink("Terms of Service") {
                    LegalDocumentView(title: "Terms of Service")
                }
                
                NavigationLink("Privacy Policy") {
                    LegalDocumentView(title: "Privacy Policy")
                }
                
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Settings")
        .alert(isPresented: $showingResetAlert) {
            Alert(
                title: Text("Reset Settings"),
                message: Text("Are you sure you want to reset all app settings to default?"),
                primaryButton: .destructive(Text("Reset")) {
                    resetSettings()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private func resetSettings() {
        notificationsEnabled = true
        emailNotificationsEnabled = true
        locationServiceEnabled = true
        currencyCode = "USD"
        darkModeEnabled = false
    }
}

// This would normally be in its own file
struct LocationRadiusSettingView: View {
    @AppStorage("searchRadiusInKm") private var searchRadiusInKm = 25.0
    
    var body: some View {
        Form {
            Section(header: Text("Search Radius")) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("\(Int(searchRadiusInKm)) km")
                        .font(.headline)
                    
                    Slider(value: $searchRadiusInKm, in: 5...100, step: 5)
                        .accentColor(.blue)
                }
                .padding(.vertical, 5)
                
                Text("Properties within this distance will appear in your nearby search results")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Nearby Search Radius")
    }
}

// This would normally be in its own file
struct ChangePasswordView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingSuccessAlert = false
    
    var body: some View {
        Form {
            Section(header: Text("Current Password")) {
                SecureField("Enter current password", text: $currentPassword)
            }
            
            Section(header: Text("New Password")) {
                SecureField("Enter new password", text: $newPassword)
                SecureField("Confirm new password", text: $confirmPassword)
                
                if newPassword.count > 0 && newPassword.count < 8 {
                    Text("Password must be at least 8 characters")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                
                if !confirmPassword.isEmpty && newPassword != confirmPassword {
                    Text("Passwords do not match")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            if let errorMessage = errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            
            Section {
                Button(action: {
                    changePassword()
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Text("Update Password")
                    }
                }
                .disabled(!isFormValid() || isLoading)
            }
        }
        .navigationTitle("Change Password")
        .alert(isPresented: $showingSuccessAlert) {
            Alert(
                title: Text("Success"),
                message: Text("Your password has been updated successfully."),
                dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    private func isFormValid() -> Bool {
        return !currentPassword.isEmpty &&
               newPassword.count >= 8 &&
               newPassword == confirmPassword
    }
    
    private func changePassword() {
        // This would call your authentication service
        isLoading = true
        
        // Simulate network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            
            // Mock success
            showingSuccessAlert = true
            
            // Mock error
            // errorMessage = "Current password is incorrect"
        }
    }
}

// This would normally be in its own file
struct PrivacySettingsView: View {
    @AppStorage("shareLocationData") private var shareLocationData = true
    @AppStorage("shareUsageData") private var shareUsageData = true
    @AppStorage("allowPersonalizedAds") private var allowPersonalizedAds = true
    
    var body: some View {
        Form {
            Section(header: Text("Data Sharing")) {
                Toggle("Share Location Data", isOn: $shareLocationData)
                    .tint(.blue)
                
                Toggle("Share Usage Data", isOn: $shareUsageData)
                    .tint(.blue)
                
                Toggle("Allow Personalized Ads", isOn: $allowPersonalizedAds)
                    .tint(.blue)
            }
            
            Section(header: Text("Your Data")) {
                NavigationLink("Download My Data") {
                    Text("Download data feature would be implemented here")
                        .padding()
                }
                
                NavigationLink("Delete My Account") {
                    DeleteAccountView()
                }
            }
        }
        .navigationTitle("Privacy Settings")
    }
}

// This would normally be in its own file
struct DeleteAccountView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var password = ""
    @State private var confirmText = ""
    @State private var showingConfirmAlert = false
    
    var body: some View {
        Form {
            Section(header: Text("Warning"), footer: Text("This action cannot be undone. All your data will be permanently deleted.")) {
                Text("Deleting your account will remove all of your information from our database. You will lose your profile, bookings, and payment information.")
                    .foregroundColor(.red)
            }
            
            Section(header: Text("Confirm Your Identity")) {
                SecureField("Enter your password", text: $password)
                
                TextField("Type 'DELETE' to confirm", text: $confirmText)
            }
            
            Section {
                Button(action: {
                    if isFormValid() {
                        showingConfirmAlert = true
                    }
                }) {
                    Text("Delete My Account")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormValid() ? Color.red : Color.gray)
                        .cornerRadius(10)
                }
                .disabled(!isFormValid())
            }
            .listRowInsets(EdgeInsets())
            .padding()
        }
        .navigationTitle("Delete Account")
        .alert(isPresented: $showingConfirmAlert) {
            Alert(
                title: Text("Delete Account"),
                message: Text("Are you absolutely sure you want to delete your account? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    // This would call your authentication service to delete the account
                    presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private func isFormValid() -> Bool {
        return !password.isEmpty && confirmText == "DELETE"
    }
}

// This would normally be in its own file
struct LegalDocumentView: View {
    let title: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // This would be replaced with actual legal content
                Text("This is placeholder text for the \(title). In a real app, this would contain the full legal document.")
                    .padding()
                
                Text("Last Updated: March 1, 2025")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
            .padding()
        }
        .navigationTitle(title)
    }
}

#Preview {
    NavigationView {
        SettingsView()
    }
}
