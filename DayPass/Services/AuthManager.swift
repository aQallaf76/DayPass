import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class AuthManager {
    static let shared = AuthManager()
    private init() {}
    
    // MARK: - Properties
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    // MARK: - User Authentication
    func isUserLoggedIn() -> Bool {
        return auth.currentUser != nil
    }
    
    func getCurrentUserId() -> String? {
        return auth.currentUser?.uid
    }
    
    func signUp(email: String, password: String, firstName: String, lastName: String, completion: @escaping (Result<User, Error>) -> Void) {
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let authResult = result, let uid = authResult.user.uid as String? else {
                completion(.failure(NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get user ID"])))
                return
            }
            
            let newUser = User(
                id: uid,
                email: email,
                firstName: firstName,
                lastName: lastName,
                phoneNumber: nil,
                profileImageURL: nil,
                favoriteProperties: [],
                createdAt: Date()
            )
            
            self.saveUserToFirestore(user: newUser) { result in
                switch result {
                case .success:
                    completion(.success(newUser))
                case .failure(let error):
                    // If saving to Firestore fails, delete the Auth user
                    // CHANGED: Using completion handler instead of try?
                    authResult.user.delete { _ in
                        // We don't care about the deletion result here
                    }
                    completion(.failure(error))
                }
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        auth.signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let uid = result?.user.uid else {
                completion(.failure(NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get user ID"])))
                return
            }
            
            self.getUserFromFirestore(userId: uid) { result in
                completion(result)
            }
        }
    }
    
    func signOut() -> Bool {
        do {
            try auth.signOut()
            return true
        } catch {
            print("Error signing out: \(error.localizedDescription)")
            return false
        }
    }
    
    func resetPassword(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        auth.sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Firestore Operations
    private func saveUserToFirestore(user: User, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = user.id else {
            completion(.failure(NSError(domain: "FirestoreError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid user ID"])))
            return
        }
        
        // Fixed version without try that was causing the error
        db.collection("users").document(userId).setData([
            "email": user.email,
            "firstName": user.firstName,
            "lastName": user.lastName,
            "phoneNumber": user.phoneNumber ?? "",
            "profileImageURL": user.profileImageURL ?? "",
            "favoriteProperties": user.favoriteProperties ?? [],
            "createdAt": Timestamp(date: user.createdAt)
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func getUserFromFirestore(userId: String, completion: @escaping (Result<User, Error>) -> Void) {
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists else {
                completion(.failure(NSError(domain: "FirestoreError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User document does not exist"])))
                return
            }
            
            // Removed the do-catch block since no throwing functions are used
            guard let data = snapshot.data() else {
                completion(.failure(NSError(domain: "FirestoreError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Document data is nil"])))
                return
            }
            
            let email = data["email"] as? String ?? ""
            let firstName = data["firstName"] as? String ?? ""
            let lastName = data["lastName"] as? String ?? ""
            let phoneNumber = data["phoneNumber"] as? String
            let profileImageURL = data["profileImageURL"] as? String
            let favoriteProperties = data["favoriteProperties"] as? [String] ?? []
            let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
            
            let user = User(
                id: userId,
                email: email,
                firstName: firstName,
                lastName: lastName,
                phoneNumber: phoneNumber,
                profileImageURL: profileImageURL,
                favoriteProperties: favoriteProperties,
                createdAt: createdAt
            )
            
            completion(.success(user))
        }
    }
    
    func getCurrentUser() -> User? {
        // Simple helper for use in the app
        guard let userId = getCurrentUserId() else { return nil }
        
        var user: User?
        let semaphore = DispatchSemaphore(value: 0)
        
        getUserFromFirestore(userId: userId) { result in
            switch result {
            case .success(let fetchedUser):
                user = fetchedUser
            case .failure:
                break
            }
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + 2.0)
        return user
    }
}
