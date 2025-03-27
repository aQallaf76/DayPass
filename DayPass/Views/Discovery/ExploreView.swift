import SwiftUI
import CoreLocation

struct ExploreView: View {
    @EnvironmentObject var propertyViewModel: PropertyViewModel
    @StateObject private var locationManager = LocationManager()
    @State private var isShowingFilter = false
    @State private var selectedTab = 0
    
    let tabs = ["All", "Nearby", "Popular", "New"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search for hotels, resorts, amenities...", text: $propertyViewModel.searchText)
                        .foregroundColor(.primary)
                    
                    if !propertyViewModel.searchText.isEmpty {
                        Button(action: {
                            propertyViewModel.searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Tabs
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(0..<tabs.count, id: \.self) { index in
                            Button(action: {
                                selectedTab = index
                                switch index {
                                case 0: // All
                                    propertyViewModel.fetchAllProperties()
                                case 1: // Nearby
                                    if let location = locationManager.location {
                                        propertyViewModel.currentLocation = location.coordinate
                                        propertyViewModel.fetchPropertiesNearby()
                                    } else {
                                        locationManager.requestLocation()
                                    }
                                case 2: // Popular - would need backend sorting by popularity
                                    propertyViewModel.fetchAllProperties()
                                case 3: // New - would need backend sorting by creation date
                                    propertyViewModel.fetchAllProperties()
                                default:
                                    break
                                }
                            }) {
                                Text(tabs[index])
                                    .fontWeight(selectedTab == index ? .bold : .regular)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 5)
                                    .foregroundColor(selectedTab == index ? .primary : .secondary)
                                    .overlay(
                                        selectedTab == index ?
                                        Rectangle()
                                            .frame(height: 2)
                                            .foregroundColor(.blue)
                                            .offset(y: 15)
                                        : nil
                                    )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 10)
                
                // Filter Button
                HStack {
                    Button(action: {
                        isShowingFilter = true
                    }) {
                        HStack {
                            Image(systemName: "slider.horizontal.3")
                            Text("Filters")
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
                
                // Properties List
                if propertyViewModel.isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if let errorMessage = propertyViewModel.errorMessage {
                    Spacer()
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                    Spacer()
                } else if propertyViewModel.filteredProperties.isEmpty {
                    Spacer()
                    VStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        
                        Text("No properties found")
                            .font(.headline)
                        
                        Text("Try adjusting your search or filters")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            ForEach(propertyViewModel.filteredProperties) { property in
                                NavigationLink(
                                    destination: PropertyDetailView(propertyId: property.id ?? "")
                                ) {
                                    PropertyCard(
                                        property: property,
                                        isFavorite: propertyViewModel.isPropertyFavorite(property),
                                        onFavoriteToggle: {
                                            propertyViewModel.toggleFavorite(property: property)
                                        }
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Explore")
            .onAppear {
                propertyViewModel.fetchAllProperties()
                propertyViewModel.fetchFavorites()
                
                // Request location if needed
                if selectedTab == 1 {
                    locationManager.requestLocation()
                }
            }
            .onChange(of: locationManager.location) { newLocation in
                if let location = newLocation, selectedTab == 1 {
                    propertyViewModel.currentLocation = location.coordinate
                    propertyViewModel.fetchPropertiesNearby()
                }
            }
            .sheet(isPresented: $isShowingFilter) {
                FilterView()
            }
        }
    }
}

// Simple Location Manager to handle location services
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.location = location
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}
