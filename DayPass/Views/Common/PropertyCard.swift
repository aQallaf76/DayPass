import SwiftUI

struct PropertyCard: View {
    let property: Property
    let isFavorite: Bool
    var onFavoriteToggle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Property Image
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: property.mainImageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .foregroundColor(.gray.opacity(0.2))
                }
                .frame(height: 200)
                .clipped()
                .cornerRadius(10)
                
                // Favorite Button
                Button(action: onFavoriteToggle) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.title2)
                        .foregroundColor(isFavorite ? .red : .white)
                        .padding(10)
                        .shadow(radius: 2)
                }
            }
            
            // Property Details
            VStack(alignment: .leading, spacing: 5) {
                // Name and Rating
                HStack {
                    Text(property.name)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if let rating = property.averageRating {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.subheadline)
                            
                            Text(String(format: "%.1f", rating))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                    }
                }
                
                // Location
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.red)
                        .font(.subheadline)
                    
                    Text("\(property.address.city), \(property.address.state)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                // Starting Price
                if let cheapestPass = property.dayPassOptions.min(by: { $0.price < $1.price }) {
                    HStack {
                        Text("From \(cheapestPass.formattedPrice)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text("per person")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Amenities Preview
                if !property.amenities.isEmpty {
                    HStack {
                        ForEach(property.amenities.prefix(3)) { amenity in
                            HStack(spacing: 2) {
                                Image(systemName: amenity.icon)
                                    .font(.caption)
                                
                                Text(amenity.name)
                                    .font(.caption)
                            }
                            .padding(.vertical, 3)
                            .padding(.horizontal, 8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(5)
                            
                            if amenity.id != property.amenities.prefix(3).last?.id {
                                Spacer()
                            }
                        }
                        
                        if property.amenities.count > 3 {
                            Text("+\(property.amenities.count - 3) more")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding(.bottom, 10)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.2), radius: 5)
    }
}
