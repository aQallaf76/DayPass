import Foundation
import FirebaseFirestoreSwift
import CoreLocation

struct Property: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var description: String
    var address: Address
    var imageURLs: [String]
    var amenities: [Amenity]
    var contactInfo: ContactInfo
    var dayPassOptions: [DayPassOption]
    var policies: Policies
    var averageRating: Double?
    var reviewCount: Int
    var isActive: Bool
    var ownerId: String
    
    var mainImageURL: String {
        return imageURLs.first ?? ""
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: address.latitude, longitude: address.longitude)
    }
}

struct Address: Codable {
    var street: String
    var city: String
    var state: String
    var zipCode: String
    var country: String
    var latitude: Double
    var longitude: Double
    
    var formattedAddress: String {
        return "\(street), \(city), \(state) \(zipCode), \(country)"
    }
}

struct ContactInfo: Codable {
    var phoneNumber: String
    var email: String
    var website: String?
}

struct Amenity: Codable, Identifiable {
    var id: String { return name }
    var name: String
    var icon: String
    var description: String?
}

struct DayPassOption: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var description: String
    var price: Double
    var currency: String
    var availableDays: [Int] // 0 = Sunday, 1 = Monday, etc.
    var startTime: String // Format: "HH:mm"
    var endTime: String // Format: "HH:mm"
    var maxCapacity: Int
    var includedAmenities: [String]
    var isActive: Bool
    
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: NSNumber(value: price)) ?? "$\(price)"
    }
    
    var timeRange: String {
        return "\(startTime) - \(endTime)"
    }
}

struct Policies: Codable {
    var cancellationPolicy: String
    var ageRestriction: Int? // Minimum age
    var dresscode: String?
    var additionalRules: [String]?
}
