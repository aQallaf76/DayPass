import Foundation

struct PaymentMethod: Identifiable {
    let id: String
    let cardType: String
    let lastFour: String
    let expiryDate: String
    let isDefault: Bool
    
    var formattedCardNumber: String {
        return "•••• •••• •••• \(lastFour)"
    }
}
