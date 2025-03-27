//
//  CancellationSheet.swift
//  DayPass
//
//  Created by Abdullah Alqallaf on 3/19/25.
//


import SwiftUI

struct CancellationSheet: View {
    let booking: Booking?
    @Binding var cancellationReason: String
    let onCancel: (Booking) -> Void
    let onConfirm: (Booking) -> Void
    
    @Environment(\.presentationMode) var presentationMode
    @State private var isConfirmingCancellation = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let booking = booking {
                    // Booking Summary
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Booking Details")
                            .font(.headline)
                        
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
                        
                        HStack {
                            Text("Guests:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("\(booking.numberOfGuests)")
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Text("Total:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text(booking.formattedPrice)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    // Cancellation Policy
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Cancellation Policy")
                            .font(.headline)
                        
                        Text("You may be eligible for a full or partial refund depending on how far in advance you cancel. Please review the property's specific cancellation policy for details.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    // Cancellation Reason
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Reason for Cancellation")
                            .font(.headline)
                        
                        TextField("Please provide a reason (optional)", text: $cancellationReason)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                    }
                    .padding()
                    
                    Spacer()
                    
                    // Buttons
                    VStack(spacing: 15) {
                        Button(action: {
                            isConfirmingCancellation = true
                        }) {
                            Text("Cancel Booking")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            onCancel(booking)
                        }) {
                            Text("Keep Booking")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .foregroundColor(.primary)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                } else {
                    Text("Unable to load booking details")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .navigationTitle("Cancel Booking")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $isConfirmingCancellation) {
                Alert(
                    title: Text("Confirm Cancellation"),
                    message: Text("Are you sure you want to cancel this booking? This action cannot be undone."),
                    primaryButton: .destructive(Text("Yes, Cancel")) {
                        if let booking = booking {
                            onConfirm(booking)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
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
        date: Date().addingTimeInterval(86400 * 2), // 2 days from now
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
    
    return CancellationSheet(
        booking: sampleBooking,
        cancellationReason: .constant(""),
        onCancel: { _ in },
        onConfirm: { _ in }
    )
}
