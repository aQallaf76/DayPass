import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirestoreManager {
    static let shared = FirestoreManager()
    private init() {}
    
    private let db = Firestore.firestore()
    
    // MARK: - Property Methods
    func fetchProperties(completion: @escaping (Result<[Property], Error>) -> Void) {
        db.collection("properties")
            .whereField("isActive", isEqualTo: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                do {
                    let properties = try documents.compactMap { try $0.data(as: Property.self) }
                    completion(.success(properties))
                } catch {
                    completion(.failure(error))
                }
            }
    }
    
    func fetchPropertiesNearLocation(latitude: Double, longitude: Double, radiusInKm: Double, completion: @escaping (Result<[Property], Error>) -> Void) {
        // In a real app, you would use geolocation queries
        // For simplicity, we'll fetch all and filter client-side
        fetchProperties { result in
            switch result {
            case .success(let properties):
                let filteredProperties = properties.filter { property in
                    let distance = self.calculateDistance(
                        lat1: latitude,
                        lon1: longitude,
                        lat2: property.address.latitude,
                        lon2: property.address.longitude
                    )
                    return distance <= radiusInKm
                }
                completion(.success(filteredProperties))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchProperty(id: String, completion: @escaping (Result<Property, Error>) -> Void) {
        db.collection("properties").document(id).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists else {
                completion(.failure(NSError(domain: "FirestoreError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Property not found"])))
                return
            }
            
            do {
                let property = try snapshot.data(as: Property.self)
                completion(.success(property))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func fetchReviewsForProperty(propertyId: String, completion: @escaping (Result<[Review], Error>) -> Void) {
        db.collection("reviews")
            .whereField("propertyId", isEqualTo: propertyId)
            .whereField("isApproved", isEqualTo: true)
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                do {
                    let reviews = try documents.compactMap { try $0.data(as: Review.self) }
                    completion(.success(reviews))
                } catch {
                    completion(.failure(error))
                }
            }
    }
    
    // MARK: - User Favorites
    func addPropertyToFavorites(userId: String, propertyId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("users").document(userId).updateData([
            "favoriteProperties": FieldValue.arrayUnion([propertyId])
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func removePropertyFromFavorites(userId: String, propertyId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("users").document(userId).updateData([
            "favoriteProperties": FieldValue.arrayRemove([propertyId])
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func fetchFavoriteProperties(userId: String, completion: @escaping (Result<[Property], Error>) -> Void) {
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists,
                  let userData = snapshot.data(),
                  let favoriteIds = userData["favoriteProperties"] as? [String] else {
                completion(.success([]))
                return
            }
            
            if favoriteIds.isEmpty {
                completion(.success([]))
                return
            }
            
            self.fetchPropertiesByIds(ids: favoriteIds, completion: completion)
        }
    }
    
    private func fetchPropertiesByIds(ids: [String], completion: @escaping (Result<[Property], Error>) -> Void) {
        // Firestore has a limit of 10 items in a whereIn query
        // For simplicity, we'll assume fewer than 10 favorites
        db.collection("properties")
            .whereField(FieldPath.documentID(), in: ids)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                do {
                    let properties = try documents.compactMap { try $0.data(as: Property.self) }
                    completion(.success(properties))
                } catch {
                    completion(.failure(error))
                }
            }
    }
    
    // MARK: - Helper Methods
    private func calculateDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let earthRadiusKm: Double = 6371
        
        let dLat = degreesToRadians(lat2 - lat1)
        let dLon = degreesToRadians(lon2 - lon1)
        
        let lat1Rad = degreesToRadians(lat1)
        let lat2Rad = degreesToRadians(lat2)
        
        let a = sin(dLat/2) * sin(dLat/2) +
                sin(dLon/2) * sin(dLon/2) * cos(lat1Rad) * cos(lat2Rad)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        return earthRadiusKm * c
    }
    
    private func degreesToRadians(_ degrees: Double) -> Double {
        return degrees * .pi / 180
    }
}
