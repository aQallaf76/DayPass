import SwiftUI

struct PaymentSuccessView: View {
    let booking: Booking
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Success animation/icon
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.green)
                    .padding()
                
                Text("Booking Confirmed!")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Your day pass has been successfully booked and confirmed.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                // Booking details
                VStack(alignment: .leading, spacing: 15) {
                    // Property info
                    HStack(alignment: .top) {
                        if let imageURL = booking.propertyImageURL {
                            AsyncImage(url: URL(string: imageURL)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(10)
                            } placeholder: {
                                Rectangle()
                                    .foregroundColor(.gray.opacity(0.2))
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(10)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text(booking.propertyName)
                                .font(.headline)
                            
                            Text(booking.dayPassName)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text(booking.formattedDate)
                                .font(.subheadline)
                            
                            Text(booking.timeRange)
                                .font(.subheadline)
                        }
                    }
                    
                    Divider()
                    
                    // Booking reference
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Booking Reference")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(booking.id ?? "Unknown")
                            .font(.headline)
                    }
                    
                    // Number of guests
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Guests")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("\(booking.numberOfGuests)")
                            .font(.headline)
                    }
                    
                    // Total paid
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Total Paid")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(booking.formattedPrice)
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(15)
                .padding(.horizontal)
                
                // QR Code
                if let qrCodeURL = booking.qrCodeURL {
                    VStack(spacing: 10) {
                        Text("Your Entry Pass")
                            .font(.headline)
                        
                        // In a real app, generate an actual QR code
                        Image(systemName: "qrcode")
                            .font(.system(size: 150))
                            .padding()
                        
                        Text("Present this QR code at the entrance")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                    .padding(.horizontal)
                }
                
                // Buttons
                VStack(spacing: 15) {
                    Button(action: {
                        // In a real app, add to wallet functionality
                    }) {
                        HStack {
                            Image(systemName: "wallet.pass")
                            Text("Add to Wallet")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    Button(action: {
                        // In a real app, share booking details
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share Booking")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                    }
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Done")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.top, 10)
                }
                .padding(.horizontal)
                .padding(.top, 20)
            }
            .padding(.vertical, 30)
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    // Create a sample booking for preview
    let sampleBooking = Booking(
        id: "BOOK123456",
        propertyId: "prop123",
        propertyName: "Luxury Beach Resort",
        propertyImageURL: nil,
        dayPassOptionId: "pass123",
        dayPassName: "Full Day Pass",
        userId: "user123",
        userEmail: "user@example.com",
        userName: "John Doe",
        date: Date(),
        startTime: "10:00 AM",
        endTime: "6:00 PM",
        numberOfGuests: 2,
        totalPrice: 120.00,
        currency: "USD",
        status: .confirmed,
        paymentId: "pay123",
        qrCodeURL: "https://example.com/qr/123",
        createdAt: Date(),
        updatedAt: nil,
        cancellationReason: nil
    )
    
    return NavigationView {
        PaymentSuccessView(booking: sampleBooking)
    }
}
