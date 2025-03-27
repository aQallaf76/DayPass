import SwiftUI

struct PaymentView: View {
    let booking: Booking
    
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var paymentViewModel = PaymentViewModel()
    
    @State private var cardNumber = ""
    @State private var cardholderName = ""
    @State private var expiryDate = ""
    @State private var cvv = ""
    @State private var showingSuccessView = false
    
    var body: some View {
        NavigationView {
            VStack {
                // If payment successful, show success view
                if paymentViewModel.paymentSuccessful {
                    PaymentSuccessView(booking: booking)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Booking Summary
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Booking Summary")
                                    .font(.headline)
                                
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(booking.propertyName)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        
                                        Text(booking.dayPassName)
                                            .font(.subheadline)
                                        
                                        Text("\(booking.formattedDate) • \(booking.timeRange)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Text("\(booking.numberOfGuests) \(booking.numberOfGuests == 1 ? "Guest" : "Guests")")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text(booking.formattedPrice)
                                        .font(.headline)
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                            
                            // Payment Form
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Payment Details")
                                    .font(.headline)
                                
                                // Card Number
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Card Number")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    TextField("0000 0000 0000 0000", text: $cardNumber)
                                        .keyboardType(.numberPad)
                                        .padding()
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(10)
                                        .onChange(of: cardNumber) { value in
                                            cardNumber = formatCardNumber(value)
                                        }
                                }
                                
                                // Cardholder Name
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Cardholder Name")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    TextField("Name on card", text: $cardholderName)
                                        .padding()
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(10)
                                }
                                
                                // Expiry and CVV
                                HStack {
                                    // Expiry Date
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("Expiry Date")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        
                                        TextField("MM/YY", text: $expiryDate)
                                            .keyboardType(.numberPad)
                                            .padding()
                                            .background(Color.gray.opacity(0.1))
                                            .cornerRadius(10)
                                            .frame(maxWidth: .infinity)
                                            .onChange(of: expiryDate) { value in
                                                expiryDate = formatExpiryDate(value)
                                            }
                                    }
                                    
                                    // CVV
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("CVV")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        
                                        SecureField("123", text: $cvv)
                                            .keyboardType(.numberPad)
                                            .padding()
                                            .background(Color.gray.opacity(0.1))
                                            .cornerRadius(10)
                                            .frame(maxWidth: .infinity)
                                            .onChange(of: cvv) { value in
                                                if value.count > 4 {
                                                    cvv = String(value.prefix(4))
                                                }
                                            }
                                    }
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                            
                            // Error Message
                            if let errorMessage = paymentViewModel.errorMessage {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .font(.subheadline)
                                    .padding()
                            }
                            
                            // Pay Button
                            Button(action: {
                                paymentViewModel.processPayment(
                                    booking: booking,
                                    cardNumber: cardNumber,
                                    cardholderName: cardholderName,
                                    expiryDate: expiryDate,
                                    cvv: cvv
                                )
                            }) {
                                if paymentViewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Pay \(booking.formattedPrice)")
                                        .fontWeight(.bold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isPaymentFormValid() ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .disabled(!isPaymentFormValid() || paymentViewModel.isLoading)
                            
                            // Security Info
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.secondary)
                                
                                Text("Your payment information is secure")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 10)
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Payment")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    // Helper method to format card number
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
    
    // Helper method to format expiry date
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
    
    // Check if payment form is valid
    private func isPaymentFormValid() -> Bool {
        let trimmedCardNumber = cardNumber.replacingOccurrences(of: " ", with: "")
        let trimmedExpiryDate = expiryDate.replacingOccurrences(of: "/", with: "")
        
        return trimmedCardNumber.count == 16 &&
               !cardholderName.isEmpty &&
               trimmedExpiryDate.count == 4 &&
               cvv.count >= 3 && cvv.count <= 4
    }
}
