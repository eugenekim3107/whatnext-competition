//
//  LocationRowView.swift
//  whatnext
//
//  Created by Eugene Kim on 1/24/24.
//
import SwiftUI
import CoreLocation
struct LocationRowView: View {
    @ObservedObject var viewModel: LocationRowViewModel
    let title: String
    let latitude: Double
    let longitude: Double
    let categories: [String]
    let radius: Double
    let curOpen: Int
    var tag: [String]? = nil
    let sortBy: String
    let limit: Int
    @State private var showingLocationDetail: Location?
    @StateObject private var locationManager = LocationManager()
    
    init(viewModel: LocationRowViewModel, title: String, latitude: Double, longitude: Double, categories: [String], radius: Double, curOpen: Int, tag: [String]? = nil, sortBy: String, limit: Int) {
        self.viewModel = viewModel
        self.title = title
        self.latitude = latitude
        self.longitude = longitude
        self.categories = categories
        self.radius = radius
        self.curOpen = curOpen
        self.tag = tag
        self.sortBy = sortBy
        self.limit = limit

        viewModel.configureAndFetchLocations(latitude: latitude, longitude: longitude, limit: limit, radius: radius, categories: categories, curOpen: curOpen, tag: tag, sortBy: sortBy)
    }
 
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 25, weight: .bold))
                .padding(.leading)
            if viewModel.locations.isEmpty {
                PlaceholderView()
            } else {
                switch viewModel.fetchState {
                case .loading, .idle, .error:
                    PlaceholderTransparentView()
                case .loaded:
                    ScrollViewReader { scrollView in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 5) {
                                ForEach(viewModel.locations, id: \.businessId) { location in
                                    LocationRowSimpleView(location: location)
                                        .onTapGesture {
                                            self.showingLocationDetail = location
                                        }
                                }
                            }
                        }
                    }
                    .sheet(item: $showingLocationDetail) { location in
                        LocationDetailView(location: location, userLocation: locationManager.currentUserLocation)
                    }
                    .padding([.leading, .trailing])
                }
            }
        }
    }
}


struct LocationRowSimpleView: View {
    var location: Location
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                if let imageUrl = location.imageUrl {
                    AsyncImageView(urlString: imageUrl)
                        .frame(width: 110, height: 110)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                } else {
                    Color.gray.opacity(0.3)
                }
                
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .resizable()
                        .frame(width: 10, height: 10)
                        .foregroundColor(.yellow)
                    Group {
                        if let stars = location.stars {
                            Text(String(format: "%.1f", stars))
                        } else {
                            Text("N/A")
                        }
                    }
                    .font(.system(size: 10))
                    .foregroundColor(.white)
                }
                .padding(3)
                .background(Color.gray)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .padding([.top, .leading], 5)
            }
            .frame(width: 110, height: 110)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            Text(location.name)
                .font(.system(size: 14))
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .truncationMode(.tail)
                .fixedSize(horizontal: false, vertical: true)
                .frame(height: 50)
                .frame(width: 110)
        }
    }
}
    
struct PlaceholderView: View {
    var body: some View {
        RoundedRectangle(cornerRadius:6)
            .fill(Color.gray.opacity(0.3))
            .frame(height: 160)
            .padding(.horizontal)
            .redacted(reason: .placeholder)
    }
}

struct PlaceholderTransparentView: View {
    var body: some View {
        RoundedRectangle(cornerRadius:6)
            .fill(Color(UIColor.systemGroupedBackground))
            .frame(height: 160)
            .padding(.horizontal)
            .redacted(reason: .placeholder)
    }
}
struct LocationRowView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = LocationRowViewModel()
        return LocationRowView(
            viewModel: viewModel,
            title: "Let's Workout!",
            latitude: 32.88088,
            longitude: -117.23790,
            categories: ["food"],
            radius: 10000,
            curOpen: 0,
            sortBy: "random",
            limit: 30
        )
    }
}


