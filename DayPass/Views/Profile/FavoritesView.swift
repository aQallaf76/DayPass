import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var propertyViewModel: PropertyViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                // Favorites view content will be implemented
                Text("Favorites View")
            }
            .padding(.vertical, 20)
        }
        .navigationTitle("Favorites")
        .onAppear {
            propertyViewModel.fetchFavorites()
        }
    }
}
