import SwiftUI

struct BookingHistoryView: View {
    @StateObject private var bookingViewModel = BookingViewModel()
    @State private var showCancellationSheet = false
    @State private var selectedBooking: Booking?
    @State private var cancellationReason = ""
    
    var body: some View {
        NavigationView {
            Group {
                if bookingViewModel.isLoading && bookingViewModel.userBookings.isEmpty {
                    VStack {
                        Spacer()
                        ProgressView()
                        Text("Loading your bookings...")
                            .foregroundColor(.secondary)
                            .padding(.top, 10)
                        Spacer()
                    }
                } else if bookingViewModel.userBookings.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Bookings Yet")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("When you book day passes, they will appear here")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        NavigationLink(destination: ExploreView()) {
                            Text("Explore Day Passes")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.horizontal, 40)
                                .padding(.top, 20)
                        }
                        
                        Spacer()
                    }
                } else {
                    List {
                        // Upcoming Bookings
                        Section(header: Text("Upcoming Bookings")) {
                            let upcomingBookings = bookingViewModel.userBookings.filter {
                                $0.date > Date() &&
                                ($0.status == .confirmed || $0.status == .pending)
                            }
                            
                            if upcomingBookings.isEmpty {
                                Text("No upcoming bookings")
                                    .foregroundColor(.secondary)
                                    .listRowBackground(Color.clear)
                            } else {
                                ForEach(upcomingBookings) { booking in
                                    BookingCell(booking: booking) {
                                        selectedBooking = booking
                                        showCancellationSheet = true
                                    }
                                    .listRowInsets(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                                }
                            }
                        }
                        
                        // Past Bookings
                        Section(header: Text("Past Bookings")) {
                            let pastBookings = bookingViewModel.userBookings.filter {
                                $0.date <= Date() && $0.status == .confirmed
                            }
                            
                            if pastBookings.isEmpty {
                                Text("No past bookings")
                                    .foregroundColor(.secondary)
                                    .listRowBackground(Color.clear)
                            } else {
                                ForEach(pastBookings) { booking in
                                    BookingCell(booking: booking)
                                    .listRowInsets(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                                }
                            }
                        }
                        
                        // Cancelled Bookings
                        Section(header: Text("Cancelled Bookings")) {
                            let cancelledBookings = bookingViewModel.userBookings.filter {
                                $0.status == .cancelled
                            }
                            
                            if cancelledBookings.isEmpty {
                                Text("No cancelled bookings")
                                    .foregroundColor(.secondary)
                                    .listRowBackground(Color.clear)
                            } else {
                                ForEach(cancelledBookings) { booking in
                                    BookingCell(booking: booking)
                                    .listRowInsets(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                                }
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .refreshable {
                        await withCheckedContinuation { continuation in
                            bookingViewModel.fetchUserBookings()
                            continuation.resume()
                        }
                    }
                }
            }
            .navigationTitle("My Bookings")
            .onAppear {
                bookingViewModel.fetchUserBookings()
            }
            .sheet(isPresented: $showCancellationSheet) {
                CancellationSheet(
                    booking: selectedBooking,
                    cancellationReason: $cancellationReason,
                    onCancel: { _ in
                        showCancellationSheet = false
                    },
                    onConfirm: { booking in
                        guard let bookingId = booking.id else { return }
                        
                        bookingViewModel.cancelBooking(
                            bookingId: bookingId,
                            reason: cancellationReason
                        ) { success in
                            if success {
                                showCancellationSheet = false
                                cancellationReason = ""
                            }
                        }
                    }
                )
            }
        }
    }
}
