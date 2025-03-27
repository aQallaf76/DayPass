import Foundation
import FirebaseFirestoreSwift

enum BookingStatus: String, Codable {
    case pending = "pending"
    case confirmed = "confirmed"
    case completed = "completed"
    case cancelled = "cancelled"
    case refunded = "refunded"
}

struct Booking: Identifiable, Codable {
    @DocumentID var id: String?
    var propertyId: String
    var propertyName: String
    var propertyImageURL: String?
    var dayPassOptionId: String
    var dayPassName: String
    var userId: String
    var userEmail: String
    var userName: String
    var date: Date
    var startTime: String
    var endTime: String
    var numberOfGuests: Int
    var totalPrice: Double
    var currency: String
    var status: BookingStatus
    var paymentId: String?
    var qrCodeURL: String?
    var createdAt: Date
    var updatedAt: Date?
    var cancellationReason: String?
    
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: NSNumber(value: totalPrice)) ?? "$\(totalPrice)"
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    var timeRange: String {
        return "\(startTime) - \(endTime)"
    }
}
