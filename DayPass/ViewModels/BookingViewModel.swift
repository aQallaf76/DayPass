import Foundation
import Combine

class BookingViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var userBookings: [Booking] = []
    @Published var currentBooking: Booking?
    @Published var availableSpots: Int?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var bookingSuccessful = false
    
    // MARK: - Booking Methods
    func fetchUserBookings() {
        guard let userId = AuthManager.shared.getCurrentUserId() else { return }
        
        isLoading = true
        errorMessage = nil
        
        BookingManager.shared.fetchUserBookings(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let bookings):
                    self?.userBookings = bookings
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func checkAvailability(propertyId: String, dayPassId: String, date: Date) {
        isLoading = true
        errorMessage = nil
        availableSpots = nil
        
        BookingManager.shared.checkDayPassAvailability(propertyId: propertyId, dayPassId: dayPassId, date: date) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let availableSpots):
                    self?.availableSpots = availableSpots
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func createBooking(property: Property, dayPass: DayPassOption, date: Date, numberOfGuests: Int) {
        guard let userId = AuthManager.shared.getCurrentUserId(),
              let propertyId = property.id,
              let dayPassId = dayPass.id,
              let user = AuthManager.shared.getCurrentUser() else {
            errorMessage = "User information is not available. Please log in."
            return
        }
        
        isLoading = true
        errorMessage = nil
        bookingSuccessful = false
        
        let booking = Booking(
            id: nil, // Will be set by createBooking
            propertyId: propertyId,
            propertyName: property.name,
            propertyImageURL: property.mainImageURL,
            dayPassOptionId: dayPassId,
            dayPassName: dayPass.name,
            userId: userId,
            userEmail: user.email,
            userName: user.fullName,
            date: date,
            startTime: dayPass.startTime,
            endTime: dayPass.endTime,
            numberOfGuests: numberOfGuests,
            totalPrice: dayPass.price * Double(numberOfGuests),
            currency: dayPass.currency,
            status: .pending, // Initially pending until payment
            paymentId: nil,
            qrCodeURL: nil,
            createdAt: Date(),
            updatedAt: nil,
            cancellationReason: nil
        )
        
        BookingManager.shared.createBooking(booking: booking) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let createdBooking):
                    self?.currentBooking = createdBooking
                    self?.bookingSuccessful = true
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func cancelBooking(bookingId: String, reason: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil
        
        BookingManager.shared.cancelBooking(bookingId: bookingId, reason: reason) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success:
                    // Update the local booking status
                    if let index = self?.userBookings.firstIndex(where: { $0.id == bookingId }) {
                        self?.userBookings[index].status = .cancelled
                        self?.userBookings[index].cancellationReason = reason
                        self?.userBookings[index].updatedAt = Date()
                    }
                    completion(true)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    func hasUserAlreadyBooked(propertyId: String, date: Date) -> Bool {
        let calendar = Calendar.current
        return userBookings.contains { booking in
            return booking.propertyId == propertyId &&
                   calendar.isDate(booking.date, inSameDayAs: date) &&
                   (booking.status == .confirmed || booking.status == .pending)
        }
    }
}
