//
//  HelpSupportView.swift
//  DayPass
//
//  Created by Abdullah Alqallaf on 3/19/25.
//

import SwiftUI

struct HelpSupportView: View {
    @State private var searchText = ""
    @State private var showingContactForm = false
    
    // Sample FAQ data
    let faqs = [
        FAQ(question: "How do I book a day pass?", answer: "You can book a day pass by selecting a property, choosing your date and preferred pass option, then proceeding through the booking and payment process."),
        FAQ(question: "Can I cancel my booking?", answer: "Yes, you can cancel your booking through the 'My Bookings' section. Refund policies vary by property and are clearly stated before you complete your booking."),
        FAQ(question: "How do I use my day pass?", answer: "Once your booking is confirmed, you'll receive a digital pass with a QR code. Simply show this to the staff at the property entrance on the day of your visit."),
        FAQ(question: "Are children allowed with day passes?", answer: "This depends on the property. Each property listing includes information about age restrictions and whether special rates for children are available."),
        FAQ(question: "What amenities are included?", answer: "The amenities included with each day pass are listed in the property details. These typically include pool access, but may also include fitness centers, spa facilities, and more."),
        FAQ(question: "Do I need to bring my own towel?", answer: "Most properties provide towels as part of the day pass, but it's always a good idea to check the property details or contact the property directly to confirm.")
    ]
    
    var filteredFAQs: [FAQ] {
        if searchText.isEmpty {
            return faqs
        } else {
            return faqs.filter { faq in
                faq.question.localizedCaseInsensitiveContains(searchText) ||
                faq.answer.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Search
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search FAQs", text: $searchText)
                        .foregroundColor(.primary)
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // FAQs
                Text("Frequently Asked Questions")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                if filteredFAQs.isEmpty {
                    Text("No matching FAQs found")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    VStack(spacing: 15) {
                        ForEach(filteredFAQs) { faq in
                            FAQItem(faq: faq)
                        }
                    }
                    .padding(.horizontal)
                }
                
                Divider()
                    .padding(.vertical)
                
                // Contact Support
                VStack(alignment: .leading, spacing: 15) {
                    Text("Need more help?")
                        .font(.headline)
                    
                    Button(action: {
                        showingContactForm = true
                    }) {
                        HStack {
                            Image(systemName: "message")
                            Text("Contact Support")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.secondary)
                        
                        Text("support@daypassapp.com")
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 5)
                    
                    HStack {
                        Image(systemName: "phone")
                            .foregroundColor(.secondary)
                        
                        Text("1-800-DAY-PASS")
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 20)
        }
        .navigationTitle("Help & Support")
        .sheet(isPresented: $showingContactForm) {
            ContactSupportView()
        }
    }
}

// FAQ model and view component
struct FAQ: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
}

struct FAQItem: View {
    let faq: FAQ
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(faq.question)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                }
            }
            
            if isExpanded {
                Text(faq.answer)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.top, 5)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct ContactSupportView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var email = ""
    @State private var subject = ""
    @State private var message = ""
    @State private var isSubmitting = false
    @State private var showingSuccessAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Your Details")) {
                    TextField("Name", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Section(header: Text("How can we help you?")) {
                    TextField("Subject", text: $subject)
                    
                    ZStack(alignment: .topLeading) {
                        if message.isEmpty {
                            Text("Describe your issue or question...")
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                                .padding(.leading, 5)
                        }
                        
                        TextEditor(text: $message)
                            .frame(minHeight: 150)
                            .padding(-5)
                    }
                }
                
                Button(action: {
                    submitForm()
                }) {
                    if isSubmitting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Text("Submit")
                    }
                }
                .frame(maxWidth: .infinity)
                .disabled(!isFormValid() || isSubmitting)
            }
            .navigationTitle("Contact Support")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .alert(isPresented: $showingSuccessAlert) {
                Alert(
                    title: Text("Message Sent"),
                    message: Text("Thank you for contacting us. We'll get back to you as soon as possible."),
                    dismissButton: .default(Text("OK")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
    }
    
    private func isFormValid() -> Bool {
        return !name.isEmpty && !email.isEmpty && !subject.isEmpty && !message.isEmpty
    }
    
    private func submitForm() {
        isSubmitting = true
        
        // Simulate network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isSubmitting = false
            showingSuccessAlert = true
        }
    }
}

#Preview {
    NavigationView {
        HelpSupportView()
    }
}
