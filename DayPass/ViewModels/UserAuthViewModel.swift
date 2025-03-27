import Foundation
import Combine
import Firebase
import FirebaseAuth

class UserAuthViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    // Initialize with a clear init method
    init() {
        // Check if user is already signed in
        checkAuthState()
    }
    
    // MARK: - Authentication Methods
    func signUp(email: String, password: String, firstName: String, lastName: String) {
        isLoading = true
        errorMessage = nil
        
        AuthManager.shared.signUp(email: email, password: password, firstName: firstName, lastName: lastName) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let user):
                    self?.user = user
                    self?.isAuthenticated = true
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func signIn(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        AuthManager.shared.signIn(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let user):
                    self?.user = user
                    self?.isAuthenticated = true
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func signOut() {
        if AuthManager.shared.signOut() {
            user = nil
            isAuthenticated = false
        } else {
            errorMessage = "Failed to sign out. Please try again."
        }
    }
    
    func resetPassword(email: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil
        
        AuthManager.shared.resetPassword(email: email) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success:
                    completion(true)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                }
            }
        }
    }
    
    func checkAuthState() {
        isAuthenticated = AuthManager.shared.isUserLoggedIn()
        
        if isAuthenticated, let user = AuthManager.shared.getCurrentUser() {
            self.user = user
        }
    }
}
