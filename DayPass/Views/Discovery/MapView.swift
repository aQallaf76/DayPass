import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var propertyViewModel: PropertyViewModel
    @StateObject private var locationManager = LocationManager()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Default to San Francisco
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var selectedProperty: Property?
    @State private var showingPropertySheet = false
    
    var body: some View {
        ZStack {
            // Map view content will be implemented
            Text("Map View")
        }
        .onAppear {
            propertyViewModel.fetchAllProperties()
        }
    }
}
