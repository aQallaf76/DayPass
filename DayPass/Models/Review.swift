import Foundation
import FirebaseFirestoreSwift

struct Review: Identifiable, Codable {
    @DocumentID var id: String?
    var propertyId: String
    var userId: String
    var userName: String
    var userImageURL: String?
    var bookingId: String?
    var rating: Int // 1-5
    var comment: String?
    var images: [String]?
    var createdAt: Date
    var updatedAt: Date?
    var isApproved: Bool
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: createdAt)
    }
}
