import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class BookingManager {
    static let shared = BookingManager()
    private init() {}
    
    private let db = Firestore.firestore()
    
    // MARK: - Booking Methods
    func createBooking(booking: Booking, completion: @escaping (Result<Booking, Error>) -> Void) {
        do {
            var mutableBooking = booking
            
            // Generate a booking reference if not provided
            if mutableBooking.id == nil {
                let ref = db.collection("bookings").document()
                mutableBooking.id = ref.documentID
            }
            
            guard let bookingId = mutableBooking.id else {
                completion(.failure(NSError(domain: "BookingError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to generate booking ID"])))
                return
            }
            
            // Save booking to Firestore
            try db.collection("bookings").document(bookingId).setData(from: mutableBooking) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(mutableBooking))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchBooking(id: String, completion: @escaping (Result<Booking, Error>) -> Void) {
        db.collection("bookings").document(id).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists else {
                completion(.failure(NSError(domain: "BookingError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Booking not found"])))
                return
            }
            
            do {
                let booking = try snapshot.data(as: Booking.self)
                completion(.success(booking))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func fetchUserBookings(userId: String, completion: @escaping (Result<[Booking], Error>) -> Void) {
        db.collection("bookings")
            .whereField("userId", isEqualTo: userId)
            .order(by: "date", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                do {
                    let bookings = try documents.compactMap { try $0.data(as: Booking.self) }
                    completion(.success(bookings))
                } catch {
                    completion(.failure(error))
                }
            }
    }
    
    func cancelBooking(bookingId: String, reason: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("bookings").document(bookingId).updateData([
            "status": BookingStatus.cancelled.rawValue,
            "cancellationReason": reason,
            "updatedAt": Timestamp(date: Date())
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Check Availability
    func checkDayPassAvailability(propertyId: String, dayPassId: String, date: Date, completion: @escaping (Result<Int, Error>) -> Void) {
        // Convert date to start of day
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: date)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
        
        // First get the day pass capacity
        db.collection("properties").document(propertyId).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            do {
                if let property = try snapshot?.data(as: Property.self),
                   let dayPass = property.dayPassOptions.first(where: { $0.id == dayPassId }) {
                    
                    // Now get the count of bookings for that day pass and date
                    self.db.collection("bookings")
                        .whereField("propertyId", isEqualTo: propertyId)
                        .whereField("dayPassOptionId", isEqualTo: dayPassId)
                        .whereField("date", isGreaterThanOrEqualTo: startDate)
                        .whereField("date", isLessThan: endDate)
                        .whereField("status", in: [BookingStatus.confirmed.rawValue, BookingStatus.pending.rawValue])
                        .getDocuments { snapshot, error in
                            if let error = error {
                                completion(.failure(error))
                                return
                            }
                            
                            let bookedCount = snapshot?.documents.reduce(0) { sum, doc in
                                if let numberOfGuests = doc.data()["numberOfGuests"] as? Int {
                                    return sum + numberOfGuests
                                }
                                return sum
                            } ?? 0
                            
                            let availableSpots = dayPass.maxCapacity - bookedCount
                            completion(.success(availableSpots))
                        }
                } else {
                    completion(.failure(NSError(domain: "BookingError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Day pass not found"])))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Generate QR Code for a Booking
    func generateQRCode(for bookingId: String) -> String? {
        // This would ideally be handled securely on the server
        // For demo purposes, just returning a placeholder URL
        // In a real app, this could be a deeplink or reference to a pass system
        return "https://daypass.app/booking/\(bookingId)"
    }
}
