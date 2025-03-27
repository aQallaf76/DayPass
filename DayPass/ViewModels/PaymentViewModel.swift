import Foundation

class PaymentViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var paymentSuccessful = false
    
    // In a real app this would integrate with a payment processor API
    func processPayment(booking: Booking, cardNumber: String, cardholderName: String, expiryDate: String, cvv: String) {
        isLoading = true
        errorMessage = nil
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            // For demo purposes, simulate successful payment with any valid card format
            let success = true // In a real app, this would be the result from the payment processor
            
            if success {
                // Update booking with payment information and status
                var updatedBooking = booking
                updatedBooking.status = .confirmed
                updatedBooking.paymentId = "PAY-\(UUID().uuidString.prefix(8))"
                updatedBooking.updatedAt = Date()
                
                // Generate QR code URL
                if let bookingId = booking.id {
                    updatedBooking.qrCodeURL = BookingManager.shared.generateQRCode(for: bookingId)
                }
                
                // Save the updated booking
                BookingManager.shared.createBooking(booking: updatedBooking) { result in
                    DispatchQueue.main.async {
                        self?.isLoading = false
                        
                        switch result {
                        case .success:
                            self?.paymentSuccessful = true
                        case .failure(let error):
                            self?.errorMessage = error.localizedDescription
                        }
                    }
                }
            } else {
                self?.isLoading = false
                self?.errorMessage = "Payment failed. Please try again."
            }
        }
    }
}
