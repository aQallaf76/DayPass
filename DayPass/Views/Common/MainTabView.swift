import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @StateObject private var propertyViewModel = PropertyViewModel()
    @StateObject private var bookingViewModel = BookingViewModel()
    
    var body: some View {
        TabView(selection: ) {
            // Explore Tab
            ExploreView()
                .environmentObject(propertyViewModel)
                .tabItem {
                    Label("Explore", systemImage: "magnifyingglass")
                }
                .tag(0)
            
            // Map Tab
            MapView()
                .environmentObject(propertyViewModel)
                .tabItem {
                    Label("Map", systemImage: "map")
                }
                .tag(1)
            
            // Bookings Tab
            BookingHistoryView()
                .environmentObject(bookingViewModel)
                .tabItem {
                    Label("Bookings", systemImage: "calendar")
                }
                .tag(2)
            
            // Profile Tab
            UserProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(3)
        }
        .onAppear {
            // Set the default appearance of tab bar
            UITabBar.appearance().backgroundColor = .systemBackground
        }
    }
}
