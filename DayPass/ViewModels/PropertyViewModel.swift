import Foundation
import Combine
import CoreLocation

class PropertyViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var properties: [Property] = []
    @Published var favoriteProperties: [Property] = []
    @Published var selectedProperty: Property?
    @Published var propertyReviews: [Review] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var currentLocation: CLLocationCoordinate2D?
    
    private var userId: String? {
        return AuthManager.shared.getCurrentUserId()
    }
    
    // MARK: - Property Methods
    func fetchAllProperties() {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        
        FirestoreManager.shared.fetchProperties { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let properties):
                    self?.properties = properties
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func fetchPropertiesNearby(radiusInKm: Double = 50.0) {
        guard !isLoading, let location = currentLocation else { return }
        isLoading = true
        errorMessage = nil
        
        FirestoreManager.shared.fetchPropertiesNearLocation(
            latitude: location.latitude,
            longitude: location.longitude,
            radiusInKm: radiusInKm
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let properties):
                    self?.properties = properties
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func fetchPropertyDetails(propertyId: String) {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        
        FirestoreManager.shared.fetchProperty(id: propertyId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let property):
                    self?.selectedProperty = property
                    self?.fetchReviewsForProperty(propertyId: propertyId)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func fetchReviewsForProperty(propertyId: String) {
        FirestoreManager.shared.fetchReviewsForProperty(propertyId: propertyId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let reviews):
                    self?.propertyReviews = reviews
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: - Favorites Methods
    func fetchFavorites() {
        guard let userId = userId else { return }
        isLoading = true
        
        FirestoreManager.shared.fetchFavoriteProperties(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let properties):
                    self?.favoriteProperties = properties
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func toggleFavorite(property: Property) {
        guard let userId = userId, let propertyId = property.id else { return }
        
        let isFavorite = favoriteProperties.contains(where: { $0.id == propertyId })
        
        if isFavorite {
            // Remove from favorites
            FirestoreManager.shared.removePropertyFromFavorites(userId: userId, propertyId: propertyId) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self?.favoriteProperties.removeAll(where: { $0.id == propertyId })
                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                    }
                }
            }
        } else {
            // Add to favorites
            FirestoreManager.shared.addPropertyToFavorites(userId: userId, propertyId: propertyId) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self?.favoriteProperties.append(property)
                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }
    
    func isPropertyFavorite(_ property: Property) -> Bool {
        guard let propertyId = property.id else { return false }
        return favoriteProperties.contains(where: { $0.id == propertyId })
    }
    
    // MARK: - Search Methods
    var filteredProperties: [Property] {
        if searchText.isEmpty {
            return properties
        } else {
            return properties.filter { property in
                property.name.localizedCaseInsensitiveContains(searchText) ||
                property.address.city.localizedCaseInsensitiveContains(searchText) ||
                property.address.state.localizedCaseInsensitiveContains(searchText) ||
                property.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}
