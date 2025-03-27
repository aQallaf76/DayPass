import SwiftUI

struct BookingView: View {
    let property: Property
    let dayPass: DayPassOption
    let date: Date
    
    @StateObject private var bookingViewModel = BookingViewModel()
    @State private var numberOfGuests = 1
    @State private var showingPaymentView = false
    @State private var showingSuccessView = false
    @State private var termsAccepted = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Property and Day Pass Summary
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Booking Details")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        HStack(alignment: .top, spacing: 15) {
                            // Property image
                            AsyncImage(url: URL(string: property.mainImageURL)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(10)
                            } placeholder: {
                                Rectangle()
                                    .foregroundColor(.gray.opacity(0.2))
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(10)
                            }
                            
                            VStack(alignment: .leading, spacing: 5) {
                                Text(property.name)
                                    .font(.headline)
                                
                                Text(property.address.city + ", " + property.address.state)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text(dayPass.name)
                                    .font(.subheadline)
                                    .padding(.vertical, 3)
                                    .padding(.horizontal, 8)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(5)
                                
                                Text(formatDate(date))
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                
                                Text(dayPass.timeRange)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    // Availability
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Availability")
                            .font(.headline)
                        
                        if bookingViewModel.isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        } else if let availableSpots = bookingViewModel.availableSpots {
                            if availableSpots > 0 {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    
                                    Text("\(availableSpots) spots available")
                                        .foregroundColor(.green)
                                }
                            } else {
                                HStack {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                    
                                    Text("No spots available on this date")
                                        .foregroundColor(.red)
                                }
                            }
                        } else if let error = bookingViewModel.errorMessage {
                            Text("Error: \(error)")
                                .foregroundColor(.red)
                                .font(.subheadline)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    // Number of Guests
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Number of Guests")
                            .font(.headline)
                        
                        Stepper("\(numberOfGuests) \(numberOfGuests == 1 ? "Guest" : "Guests")", value: $numberOfGuests, in: 1...10)
                            .disabled(bookingViewModel.availableSpots == nil || bookingViewModel.availableSpots! < 1)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    // Price Calculation
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Price Details")
                            .font(.headline)
                        
                        HStack {
                            Text("\(dayPass.name)")
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Text("\(dayPass.formattedPrice) x \(numberOfGuests)")
                                .font(.subheadline)
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Total")
                                .font(.headline)
                            
                            Spacer()
                            
                            Text(formatPrice(dayPass.price * Double(numberOfGuests), currency: dayPass.currency))
                                .font(.headline)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    // Cancellation Policy
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Cancellation Policy")
                            .font(.headline)
                        
                        Text(property.policies.cancellationPolicy)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    // Terms and Conditions
                    Toggle(isOn: $termsAccepted) {
                        Text("I agree to the terms and conditions")
                            .font(.subheadline)
                    }
                    .padding()
                    
                    // Error Message
                    if let errorMessage = bookingViewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.subheadline)
                            .padding()
                    }
                    
                    // Book Now Button
                    Button(action: {
                        bookingViewModel.createBooking(
                            property: property,
                            dayPass: dayPass,
                            date: date,
                            numberOfGuests: numberOfGuests
                        )
                    }) {
                        if bookingViewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Proceed to Payment")
                                .fontWeight(.bold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isBookingEnabled() ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(!isBookingEnabled())
                    .padding(.bottom, 30)
                }
                .padding()
            }
            .navigationTitle("Booking")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if let propertyId = property.id, let dayPassId = dayPass.id {
                    bookingViewModel.checkAvailability(
                        propertyId: propertyId,
                        dayPassId: dayPassId,
                        date: date
                    )
                }
                
                // Also fetch user bookings to check for duplicates
                bookingViewModel.fetchUserBookings()
            }
            .onChange(of: bookingViewModel.bookingSuccessful) { success in
                if success {
                    showingPaymentView = true
                }
            }
            .sheet(isPresented: $showingPaymentView) {
                if let booking = bookingViewModel.currentBooking {
                    PaymentView(booking: booking)
                }
            }
        }
    }
    
    // Helper method to format date
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
    
    // Helper method to format price
    private func formatPrice(_ price: Double, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: NSNumber(value: price)) ?? "$\(price)"
    }
    
    // Check if booking should be enabled
    private func isBookingEnabled() -> Bool {
        return !bookingViewModel.isLoading &&
               bookingViewModel.availableSpots != nil &&
               bookingViewModel.availableSpots! >= numberOfGuests &&
               termsAccepted &&
               !bookingViewModel.hasUserAlreadyBooked(propertyId: property.id ?? "", date: date)
    }
}
