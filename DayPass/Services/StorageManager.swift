import Foundation
import FirebaseStorage

class StorageManager {
    static let shared = StorageManager()
    private init() {}
    
    private let storage = Storage.storage()
    
    // MARK: - Upload Methods
    func uploadProfileImage(userId: String, imageData: Data, completion: @escaping (Result<String, Error>) -> Void) {
        // Implement upload profile image
    }
    
    func uploadPropertyImage(propertyId: String, imageData: Data, completion: @escaping (Result<String, Error>) -> Void) {
        // Implement upload property image
    }
    
    // MARK: - Delete Methods
    func deleteImage(at path: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Implement delete image
    }
}
