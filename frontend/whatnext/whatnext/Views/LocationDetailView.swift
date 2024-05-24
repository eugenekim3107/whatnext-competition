//
//  LocationDetailView.swift
//  whatnext
//
//  Created by Mike Dong on 2/4/24.
//

import SwiftUI
import CoreLocation

struct LocationDetailView: View {
    let location: Location
    let userLocation: CLLocation?
    @AppStorage("userID") var loginUserID: String = ""
    @State private var isFavorite: Bool = false
    @State private var isVisited: Bool = false
    
   
    private let profileService = ProfileService()


    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ZStack(alignment: .topTrailing) {
                    ImageView(imageUrl: location.imageUrl)
                    
                    // Favorite and Visited buttons placed in the top right corner
                    HStack(spacing: 10) {
                        // Favorite Button
                        Button(action: {
                            self.isFavorite.toggle()
                            // Placeholder function to update favorite status
                        }) {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .foregroundColor(isFavorite ? .red : .gray)
                                .padding(8)
                                .background(Circle().fill(Color.white))
                                .shadow(radius: 3)
                        }

                        // Visited Button
                        Button(action: {
                            self.isVisited.toggle()
                            // Placeholder function to update visited status
                        }) {
                            Image(systemName: isVisited ? "checkmark.circle.fill" : "checkmark.circle")
                                .foregroundColor(isVisited ? .green : .gray)
                                .padding(8)
                                .background(Circle().fill(Color.white))
                                .shadow(radius: 3)
                        }
                    }
                    .padding(8)
                }
                
                BusinessInfo(name: location.name, stars: location.stars, reviewCount: location.reviewCount)
                PriceAndCategoryView(price: location.price, tag: location.tag)
                HoursView(hours: location.hours)
                ContactInfo(displayPhone: location.displayPhone, address: location.address, city: location.city, state: location.state, postalCode: location.postalCode)
                
                if let userLocation = userLocation, let locationLatitude = location.latitude, let locationLongitude = location.longitude {
                    let locationCLLocation = CLLocation(latitude: locationLatitude, longitude: locationLongitude)
                    let distanceInMeters = userLocation.distance(from: locationCLLocation)
                    
                    Text(String(format: "%.2f meters away", distanceInMeters))
                        .padding()
                }
            }
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(10)
        .navigationBarTitleDisplayMode(.inline)
    }

}


// ImageView for displaying the location's image
struct ImageView: View {
    let imageUrl: String?

    var body: some View {
        if let imageUrl = imageUrl, let url = URL(string: imageUrl) {
            AsyncImage(url: url) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2.2)
                        .clipped()
                } else if phase.error != nil {
                    Color.gray.opacity(0.3)
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2.2)
                } else {
                    Color.gray.opacity(0.3)
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2.2)
                }
            }
        } else {
            Color.gray.opacity(0.3)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2.2)
        }
    }
}


// BusinessInfo for displaying the business name and ratings
struct BusinessInfo: View {
    let name: String
    let stars: Double?
    let reviewCount: Int?

    var body: some View {
        VStack(alignment: .leading) {
            Text(name)
                .font(.largeTitle)
                .bold()
                .foregroundColor(Color.primary)

            HStack {
                StarRatingView(stars: Int(stars ?? 0))
                if let stars = stars, let reviewCount = reviewCount {
                    Text("\(String(format: "%.1f", stars)) (\(reviewCount) reviews)")
                        .font(.caption)
                        .foregroundColor(Color.primary)
                        
                }
            }
        }
        .padding()
    }
}

// StarRatingView for displaying star ratings
struct StarRatingView: View {
    let stars: Int
    var body: some View {
        HStack {
            ForEach(0..<5, id: \.self) { star in
                Image(systemName: star < stars ? "star.fill" : "star")
                    .foregroundColor(star < stars ? .yellow : .gray)
            }
        }
    }
}

// PriceAndCategoryView for displaying the price and categories
struct PriceAndCategoryView: View {
    let price: String?
    let tag: [String]?

    var body: some View {
        Divider()
            .background(Color.blue)
        HStack {
            if let price = price {
                Text(price)
                    .bold()
                    .padding(5)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(5)
            }

            ForEach(tag?.map { $0.replacingOccurrences(of: "_", with: " ").capitalized } ?? [], id: \.self) { category in
                Text(category)
                    .padding(6)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .foregroundColor(.primary) // Adapts automatically to light/dark mode
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal)
        .cornerRadius(10)
    }
}

struct HoursView: View {
    let hours: Hours?
    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Divider()
                .background(Color.blue)
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text("Hours")
                        .foregroundColor(Color.primary)
                        .foregroundColor(isOpenNow(hours: hours) ? .green : .red)
                    Spacer()
                    Text(isOpenNow(hours: hours) ? "OPEN" : "CLOSED")
                        .foregroundColor(Color.primary)
                        .padding(5)
                        .background(isOpenNow(hours: hours) ? Color.green : Color.red)
                        .cornerRadius(10)
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .animation(.easeOut, value: isExpanded)
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 40)
                .animation(.easeOut, value: isExpanded)
            }
            
            if isExpanded, let formattedHours = hours?.formattedHours.sorted(by: { $0.key < $1.key }) {
                ForEach(formattedHours, id: \.key) { day, hours in
                    HStack {
                        Text(day + ":")
                            .bold()
                        Spacer()
                        Text(hours)
                    }
                    .padding(.horizontal, 40)
                    .padding(.vertical, 2)
                    .transition(.opacity.combined(with: .slide))
                }
            }
            Divider()
                .background(Color.blue)
        }
        
    }
    private func isOpenNow(hours: Hours?) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        let dayOfWeek = calendar.weekdaySymbols[calendar.component(.weekday, from: now) - 1]

        guard let todayHours = hours?.hours(for: dayOfWeek) else { return false }
        
        if todayHours.open == "0000" && todayHours.close == "0000" {
            return true
        }

        let currentTime = calendar.component(.hour, from: now) * 100 + calendar.component(.minute, from: now)
        let openingTime = Int(todayHours.open.replacingOccurrences(of: ":", with: "")) ?? 0
        let closingTime = Int(todayHours.close.replacingOccurrences(of: ":", with: "")) ?? 2400 // Use 2400 for end of day

        if closingTime < openingTime {
            return currentTime >= openingTime || currentTime < closingTime
        } else {
            return currentTime >= openingTime && currentTime < closingTime
        }
    }
}


// ContactInfo for displaying phone and address
struct ContactInfo: View {
    let displayPhone: String?
    let address: String?
    let city: String?
    let state: String?
    let postalCode: String?

    var body: some View {
        VStack(alignment: .leading) {
            if let displayPhone = displayPhone {
                Text("Phone: \(displayPhone)")
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 40)
        .cornerRadius(10)
        Divider()
            .background(Color.blue)
        VStack(alignment: .leading) {
            if let address = address, let city = city, let state = state, let postalCode = postalCode {
                Text("Address: \(address), \(city), \(state) \(postalCode)")
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 40)
        .cornerRadius(10)
    }
}

// This extension is used in HoursView to format the hours string
extension String {
    func insert(separator: String, every n: Int) -> String {
        var result: String = ""
        var count = 0
        for char in self {
            if count % n == 0 && count > 0 {
                result += separator
            }
            result += String(char)
            count += 1
        }
        return result
    }
}

// This extension is used in HoursView to get a sorted array of key-value pairs
extension Dictionary where Key == String, Value == [String] {
    var keyValuePairs: [(key: String, value: [String])] {
        return map { (key, value) in (key, value) }.sorted { $0.key < $1.key }
    }
}

struct LocationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        LocationDetailView(location: Location(
            businessId: "1",
            name: "Shorehouse Kitchen",
            imageUrl: "https://s3-media2.fl.yelpcdn.com/bphoto/cln5YeBlyDYnhYU8fASAng/o.jpg",
            phone: "+18584593300",
            displayPhone: "(858) 459-3300",
            address: "2236 Avenida De La Playa",
            city: "La Jolla",
            state: "CA",
            postalCode: "92037",
            latitude: 32.8539270057529,
            longitude: -117.254643428836,
            stars: 4.5,
            reviewCount: 2098,
            curOpen: 0,
            categories: ["New American", "Salad", "Sandwiches"],
            tag: ["coffee", "breakfast_brunch", "newamerican"],
            hours: Hours(
                Monday: ["0730","1430"],
                Tuesday: ["0730","1430"],
                Wednesday: ["0730","1430"],
                Thursday: ["0730","1430"],
                Friday: ["0730","1530"],
                Saturday: ["0730","1530"],
                Sunday: ["0730","1530"]
            ),
            location: GeoJSON(type: "Point", coordinates: [-117.254643428836, 32.8539270057529]),
            price: "$$"
        ), userLocation: CLLocation(latitude: 32.88088, longitude: -117.2379))
    }
}
