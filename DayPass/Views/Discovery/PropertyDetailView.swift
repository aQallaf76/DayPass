import SwiftUI

struct PropertyDetailView: View {
    let propertyId: String
    @EnvironmentObject var propertyViewModel: PropertyViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedImageIndex = 0
    @State private var selectedDate: Date = Date()
    @State private var showingBookingView = false
    @State private var selectedDayPass: DayPassOption?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Image Gallery
                if let property = propertyViewModel.selectedProperty {
                    // Image Carousel
                    TabView(selection: $selectedImageIndex) {
                        ForEach(0..<property.imageURLs.count, id: \.self) { index in
                            AsyncImage(url: URL(string: property.imageURLs[index])) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Rectangle()
                                    .foregroundColor(.gray.opacity(0.2))
                            }
                            .tag(index)
                        }
                    }
                    .frame(height: 300)
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                    
                    // Property Details
                    VStack(alignment: .leading, spacing: 15) {
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(property.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                HStack {
                                    Image(systemName: "mappin.circle.fill")
                                        .foregroundColor(.red)
                                    
                                    Text(property.address.formattedAddress)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            // Favorite button
                            Button(action: {
                                propertyViewModel.toggleFavorite(property: property)
                            }) {
                                Image(systemName: propertyViewModel.isPropertyFavorite(property) ? "heart.fill" : "heart")
                                    .font(.title2)
                                    .foregroundColor(propertyViewModel.isPropertyFavorite(property) ? .red : .gray)
                            }
                        }
                        
                        Divider()
                        
                        // Rating
                        if let rating = property.averageRating {
                            HStack(spacing: 5) {
                                ForEach(1...5, id: \.self) { star in
                                    Image(systemName: star <= Int(rating) ? "star.fill" : (star-0.5 <= rating ? "star.leadinghalf.fill" : "star"))
                                        .foregroundColor(.yellow)
                                }
                                
                                Text(String(format: "%.1f", rating))
                                    .fontWeight(.semibold)
                                
                                Text("(\(property.reviewCount) reviews)")
                                    .foregroundColor(.secondary)
                            }
                            
                            Divider()
                        }
                        
                        // Description
                        Text("About")
                            .font(.headline)
                        
                        Text(property.description)
                            .foregroundColor(.secondary)
                        
                        Divider()
                        
                        // Amenities
                        Text("Amenities")
                            .font(.headline)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(property.amenities) { amenity in
                                HStack {
                                    Image(systemName: amenity.icon)
                                        .foregroundColor(.blue)
                                    
                                    Text(amenity.name)
                                        .font(.subheadline)
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 5)
                            }
                        }
                        
                        Divider()
                        
                        // Day Pass Options
                        Text("Day Pass Options")
                            .font(.headline)
                        
                        // Date Picker
                        DatePicker("Select Date", selection: $selectedDate, in: Date()..., displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .frame(maxHeight: 400)
                        
                        // Available Passes for Selected Date
                        let availablePasses = property.dayPassOptions.filter { pass in
                            // Check if the pass is available on the selected day of week
                            let calendar = Calendar.current
                            let weekday = calendar.component(.weekday, from: selectedDate) - 1 // 0 = Sunday, 1 = Monday, etc.
                            return pass.isActive && pass.availableDays.contains(weekday)
                        }
                        
                        if availablePasses.isEmpty {
                            Text("No day passes available for this date")
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            ForEach(availablePasses) { pass in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text(pass.name)
                                                .font(.headline)
                                            
                                            Text(pass.timeRange)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        VStack(alignment: .trailing, spacing: 5) {
                                            Text(pass.formattedPrice)
                                                .font(.headline)
                                            
                                            Text("per person")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Text(pass.description)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    Button(action: {
                                        selectedDayPass = pass
                                        showingBookingView = true
                                    }) {
                                        Text("Book Now")
                                            .fontWeight(.bold)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                    }
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                                .padding(.vertical, 5)
                            }
                        }
                        
                        Divider()
                        
                        // Reviews
                        HStack {
                            Text("Reviews")
                                .font(.headline)
                            
                            Spacer()
                            
                            NavigationLink(destination: AllReviewsView(propertyId: propertyId)) {
                                Text("See all")
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        if propertyViewModel.propertyReviews.isEmpty {
                            Text("No reviews yet")
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            ForEach(propertyViewModel.propertyReviews.prefix(3)) { review in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        // User image
                                        if let imageURL = review.userImageURL, !imageURL.isEmpty {
                                            AsyncImage(url: URL(string: imageURL)) { image in
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 40, height: 40)
                                                    .clipShape(Circle())
                                            } placeholder: {
                                                Circle()
                                                    .foregroundColor(.gray.opacity(0.2))
                                                    .frame(width: 40, height: 40)
                                            }
                                        } else {
                                            Image(systemName: "person.circle.fill")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 40, height: 40)
                                                .foregroundColor(.gray)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(review.userName)
                                                .font(.headline)
                                            
                                            Text(review.formattedDate)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        // Star rating
                                        HStack(spacing: 2) {
                                            ForEach(1...5, id: \.self) { star in
                                                Image(systemName: star <= review.rating ? "star.fill" : "star")
                                                    .foregroundColor(.yellow)
                                                    .font(.caption)
                                            }
                                        }
                                    }
                                    
                                    if let comment = review.comment, !comment.isEmpty {
                                        Text(comment)
                                            .font(.subheadline)
                                    }
                                    
                                    // Review images (if any)
                                    if let images = review.images, !images.isEmpty {
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack(spacing: 10) {
                                                ForEach(images, id: \.self) { imageUrl in
                                                    AsyncImage(url: URL(string: imageUrl)) { image in
                                                        image
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fill)
                                                            .frame(width: 80, height: 80)
                                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                                    } placeholder: {
                                                        Rectangle()
                                                            .foregroundColor(.gray.opacity(0.2))
                                                            .frame(width: 80, height: 80)
                                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                                .padding(.vertical, 5)
                            }
                        }
                    }
                    .padding()
                } else if propertyViewModel.isLoading {
                    VStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .frame(height: 300)
                } else if let error = propertyViewModel.errorMessage {
                    VStack {
                        Spacer()
                        Text("Error: \(error)")
                            .foregroundColor(.red)
                        Spacer()
                    }
                    .frame(height: 300)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            propertyViewModel.fetchPropertyDetails(propertyId: propertyId)
        }
        .sheet(isPresented: $showingBookingView) {
            if let property = propertyViewModel.selectedProperty, let dayPass = selectedDayPass {
                BookingView(
                    property: property,
                    dayPass: dayPass,
                    date: selectedDate
                )
            }
        }
    }
}
