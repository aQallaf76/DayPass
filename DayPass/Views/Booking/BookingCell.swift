import SwiftUI

struct BookingCell: View {
    let booking: Booking
    var onCancelTap: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Property Info Row
            HStack(alignment: .top, spacing: 12) {
                // Property Image
                if let imageURL = booking.propertyImageURL {
                    AsyncImage(url: URL(string: imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 70, height: 70)
                            .cornerRadius(8)
                    } placeholder: {
                        Rectangle()
                            .foregroundColor(.gray.opacity(0.2))
                            .frame(width: 70, height: 70)
                            .cornerRadius(8)
                    }
                } else {
                    Rectangle()
                        .foregroundColor(.gray.opacity(0.2))
                        .frame(width: 70, height: 70)
                        .cornerRadius(8)
                }
                
                // Property Details
                VStack(alignment: .leading, spacing: 4) {
                    Text(booking.propertyName)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Text(booking.dayPassName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    HStack {
                        Image(systemName: "calendar")
                            .font(.caption)
                            .foregroundColor(.blue)
                        
                        Text(booking.formattedDate)
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                    
                    HStack {
                        Image(systemName: "clock")
                            .font(.caption)
                            .foregroundColor(.blue)
                        
                        Text(booking.timeRange)
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                }
                
                Spacer()
                
                // Status Badge
                statusBadge
            }
            
            // Bottom Row with Price & Actions
            HStack {
                // Guest Count
                HStack {
                    Image(systemName: "person")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(booking.numberOfGuests) \(booking.numberOfGuests == 1 ? "Guest" : "Guests")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Price
                Text(booking.formattedPrice)
                    .font(.callout)
                    .fontWeight(.semibold)
            }
            
            // Cancellation Button (only for upcoming bookings that can be cancelled)
            if canBeCancelled && onCancelTap != nil {
                Button(action: {
                    onCancelTap?()
                }) {
                    Text("Cancel Booking")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .foregroundColor(.red)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(5)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding(10)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // Status Badge View
    private var statusBadge: some View {
        Group {
            switch booking.status {
            case .pending:
                Text("Pending")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.orange)
                    .padding(.vertical, 3)
                    .padding(.horizontal, 8)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(5)
                
            case .confirmed:
                let isUpcoming = booking.date > Date()
                
                Text(isUpcoming ? "Confirmed" : "Completed")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isUpcoming ? .green : .blue)
                    .padding(.vertical, 3)
                    .padding(.horizontal, 8)
                    .background(Color(isUpcoming ? .green : .blue).opacity(0.1))
                    .cornerRadius(5)
                
            case .cancelled:
                Text("Cancelled")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.red)
                    .padding(.vertical, 3)
                    .padding(.horizontal, 8)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(5)
                
            case .completed:
                Text("Completed")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                    .padding(.vertical, 3)
                    .padding(.horizontal, 8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(5)
                
            case .refunded:
                Text("Refunded")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.purple)
                    .padding(.vertical, 3)
                    .padding(.horizontal, 8)
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(5)
            }
        }
    }
    
    // Helper to determine if booking can be cancelled
    private var canBeCancelled: Bool {
        let isUpcoming = booking.date > Date()
        return isUpcoming && booking.status == .confirmed
    }
}
