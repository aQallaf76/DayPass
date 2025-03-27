import Foundation
import FirebaseFirestoreSwift

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var email: String
    var firstName: String
    var lastName: String
    var phoneNumber: String?
    var profileImageURL: String?
    var favoriteProperties: [String]?
    var createdAt: Date
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
}
