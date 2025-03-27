import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var showLogin = false
    
    let pages: [(image: String, title: String, description: String)] = [
        (
            image: "beach.umbrella",
            title: "Welcome to DayPass",
            description: "Your gateway to luxury experiences at hotels and resorts worldwide"
        ),
        (
            image: "magnifyingglass",
            title: "Discover and Explore",
            description: "Find the perfect day pass for pools, spas, beaches, and more near you"
        ),
        (
            image: "creditcard",
            title: "Easy Booking",
            description: "Reserve and pay for day passes in seconds, no membership required"
        ),
        (
            image: "qrcode",
            title: "Digital Access",
            description: "Use your digital pass for seamless entry to your reserved amenities"
        )
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                // Skip Button
                HStack {
                    Spacer()
                    Button(action: {
                        showLogin = true
                    }) {
                        Text("Skip")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
                
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count) { index in
                        VStack(spacing: 20) {
                            Image(systemName: pages[index].image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 150, height: 150)
                                .foregroundColor(.blue)
                                .padding(.bottom, 30)
                            
                            Text(pages[index].title)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            
                            Text(pages[index].description)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 40)
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                
                // Next or Get Started Button
                Button(action: {
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        showLogin = true
                    }
                }) {
                    Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
            .background(
                NavigationLink(
                    destination: LoginView(),
                    isActive: $showLogin,
                    label: { EmptyView() }
                )
            )
        }
    }
}
