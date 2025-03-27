import Foundation
import UIKit

// Format date to string
func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter.string(from: date)
}

// Format price with currency
func formatPrice(_ price: Double, currency: String = "USD") -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = currency
    return formatter.string(from: NSNumber(value: price)) ?? "$\(price)"
}

// Generate a random color from a string (e.g., for user avatars)
func generateColor(from string: String) -> UIColor {
    var hash = 0
    for char in string.unicodeScalars {
        hash = Int(char.value) &+ ((hash << 5) &- hash)
    }
    let red = CGFloat((hash >> 16) & 0xFF) / 255.0
    let green = CGFloat((hash >> 8) & 0xFF) / 255.0
    let blue = CGFloat(hash & 0xFF) / 255.0
    
    return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
}
