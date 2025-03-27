//
//  ContactInfoView.swift
//  DayPass
//
//  Created by Abdullah Alqallaf on 3/19/25.
//

import SwiftUI

struct ContactInfoView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = ContactInfoViewModel()
    @State private var isEditing = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Contact Information
                VStack(alignment: .leading, spacing: 15) {
                    Text("Email")
                        .font(.headline)
                    
                    if isEditing {
                        Text(viewModel.email)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                    } else {
                        Text(viewModel.email)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("Phone Number")
                        .font(.headline)
                    
                    if isEditing {
                        TextField("Phone Number", text: $viewModel.phoneNumber)
                            .keyboardType(.phonePad)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                    } else {
                        Text(viewModel.phoneNumber.isEmpty ? "Not provided" : viewModel.phoneNumber)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                
                // Action Buttons
                if isEditing {
                    HStack(spacing: 20) {
                        Button(action: {
                            isEditing = false
                            viewModel.resetForm()
                        }) {
                            Text("Cancel")
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .foregroundColor(.primary)
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            viewModel.updateContactInfo {
                                isEditing = false
                            }
                        }) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Save")
                                    .fontWeight(.medium)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .disabled(viewModel.isLoading)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                } else {
                    Button(action: {
                        isEditing = true
                    }) {
                        HStack {
                            Image(systemName: "pencil")
                            Text("Edit Contact Info")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                }
                
                Spacer()
            }
            .padding(.vertical, 20)
        }
        .navigationTitle("Contact Information")
        .alert(item: $viewModel.alertItem) { alertItem in
            Alert(
                title: Text(alertItem.title),
                message: Text(alertItem.message),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            viewModel.loadContactInfo()
        }
    }
}

// ContactInfoViewModel.swift would be needed but it's assumed to be already created
// in your ViewModels directory

#Preview {
    NavigationView {
        ContactInfoView()
            .environmentObject(AuthViewModel())
    }
}
