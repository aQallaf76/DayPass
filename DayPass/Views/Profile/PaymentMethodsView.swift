//
//  PaymentMethodsView.swift
//  DayPass
//
//  Created by Abdullah Alqallaf on 3/19/25.
//

import SwiftUI

struct PaymentMethodsView: View {
    @StateObject private var viewModel = PaymentMethodsViewModel()
    @State private var showingAddCard = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if viewModel.isLoading {
                    ProgressView()
                        .padding(.top, 50)
                } else if viewModel.paymentMethods.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "creditcard")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                            .padding(.top, 50)
                        
                        Text("No Payment Methods")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Add a credit or debit card to make booking faster and easier")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 50)
                    }
                } else {
                    ForEach(viewModel.paymentMethods) { method in
                        PaymentMethodCard(method: method) {
                            viewModel.removePaymentMethod(id: method.id)
                        }
                    }
                    .padding(.horizontal)
                }
                
                Button(action: {
                    showingAddCard = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Add Payment Method")
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
            .padding(.vertical, 20)
        }
        .navigationTitle("Payment Methods")
        .sheet(isPresented: $showingAddCard) {
            AddPaymentMethodView { newMethod in
                viewModel.addPaymentMethod(method: newMethod)
                showingAddCard = false
            }
        }
        .alert(item: $viewModel.alertItem) { alertItem in
            Alert(
                title: Text(alertItem.title),
                message: Text(alertItem.message),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            viewModel.loadPaymentMethods()
        }
    }
}

struct PaymentMethodCard: View {
    let method: PaymentMethod
    let onDelete: () -> Void
    @State private var showingDeleteAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: getCardSystemIcon(method.cardType))
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Text(method.cardType)
                    .font(.headline)
                
                Spacer()
                
                if method.isDefault {
                    Text("Default")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
            }
            
            Text(method.formattedCardNumber)
                .font(.title3)
            
            HStack {
                Text("Expires \(method.expiryDate)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: {
                    showingDeleteAlert = true
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Remove Payment Method"),
                message: Text("Are you sure you want to remove this card?"),
                primaryButton: .destructive(Text("Remove")) {
                    onDelete()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private func getCardSystemIcon(_ cardType: String) -> String {
        switch cardType.lowercased() {
        case "visa":
            return "creditcard"
        case "mastercard":
            return "creditcard"
        case "amex", "american express":
            return "creditcard"
        default:
            return "creditcard"
        }
    }
}

struct AddPaymentMethodView: View {
    let onAdd: (PaymentMethod) -> Void
    
    @Environment(\.presentationMode) var presentationMode
    @State private var cardNumber = ""
    @State private var cardholderName = ""
    @State private var expiryDate = ""
    @State private var cvv = ""
    @State private var isDefault = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Add Payment Method")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top)
                        .padding(.horizontal)
                    
                    // Card Number
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Card Number")
                            .font(.headline)
                        
                        TextField("0000 0000 0000 0000", text: $cardNumber)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                            .onChange(of: cardNumber) { value in
                                cardNumber = formatCardNumber(value)
                            }
                    }
                    .padding(.horizontal)
                    
                    // Cardholder Name
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Cardholder Name")
                            .font(.headline)
                        
                        TextField("Name on card", text: $cardholderName)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // Expiry and CVV
                    HStack {
                        // Expiry Date
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Expiry Date")
                                .font(.headline)
                            
                            TextField("MM/YY", text: $expiryDate)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                                .onChange(of: expiryDate) { value in
                                    expiryDate = formatExpiryDate(value)
                                }
                        }
                        
                        // CVV
                        VStack(alignment: .leading, spacing: 5) {
                            Text("CVV")
                                .font(.headline)
                            
                            SecureField("123", text: $cvv)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                                .onChange(of: cvv) { value in
                                    if value.count > 4 {
                                        cvv = String(value.prefix(4))
                                    }
                                }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Default Card Toggle
                    Toggle("Set as default payment method", isOn: $isDefault)
                        .padding(.horizontal)
                        .padding(.top, 10)
                    
                    // Security Message
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.secondary)
                        
                        Text("Your payment information is secure")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Add Button
                    Button(action: {
                        let trimmedCardNumber = cardNumber.replacingOccurrences(of: " ", with: "")
                        let lastFour = String(trimmedCardNumber.suffix(4))
                        
                        let newMethod = PaymentMethod(
                            id: "card_\(UUID().uuidString)",
                            cardType: determineCardType(cardNumber),
                            lastFour: lastFour,
                            expiryDate: expiryDate,
                            isDefault: isDefault
                        )
                        
                        onAdd(newMethod)
                    }) {
                        Text("Add Card")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isFormValid() ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(!isFormValid())
                    .padding()
                }
            }
            .navigationBarItems(
                trailing: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    private func formatCardNumber(_ number: String) -> String {
        let trimmed = number.replacingOccurrences(of: " ", with: "")
        if trimmed.count > 16 {
            return String(trimmed.prefix(16))
                .enumerated()
                .map { $0.offset > 0 && $0.offset % 4 == 0 ? " \($0.element)" : String($0.element) }
                .joined()
        }
        
        return trimmed
            .enumerated()
            .map { $0.offset > 0 && $0.offset % 4 == 0 ? " \($0.element)" : String($0.element) }
            .joined()
    }
    
    private func formatExpiryDate(_ date: String) -> String {
        let trimmed = date.replacingOccurrences(of: "/", with: "")
        if trimmed.count > 4 {
            return String(trimmed.prefix(4))
                .enumerated()
                .map { $0.offset == 2 ? "/\($0.element)" : String($0.element) }
                .joined()
        }
        
        return trimmed
            .enumerated()
            .map { $0.offset == 2 && trimmed.count > 2 ? "/\($0.element)" : String($0.element) }
            .joined()
    }
    
    private func isFormValid() -> Bool {
        let trimmedCardNumber = cardNumber.replacingOccurrences(of: " ", with: "")
        let trimmedExpiryDate = expiryDate.replacingOccurrences(of: "/", with: "")
        
        return trimmedCardNumber.count == 16 &&
               !cardholderName.isEmpty &&
               trimmedExpiryDate.count == 4 &&
               cvv.count >= 3 && cvv.count <= 4
    }
    
    private func determineCardType(_ cardNumber: String) -> String {
        // Very simplified detection
        let firstDigit = cardNumber.first
        
        if firstDigit == "4" {
            return "Visa"
        } else if firstDigit == "5" {
            return "Mastercard"
        } else if firstDigit == "3" {
            return "American Express"
        } else {
            return "Credit Card"
        }
    }
}

#Preview {
    NavigationView {
        PaymentMethodsView()
    }
}
