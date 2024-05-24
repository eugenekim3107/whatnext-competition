//
//  FavoritesRowView.swift
//  whatnext
//
//  Created by Eugene Kim on 2/21/24.
//

import SwiftUI
import CoreLocation

struct FavoritesRowView: View {
    @ObservedObject var viewModel: LocationRowViewModel
    let title: String
    let userId: String
    @State private var showingLocationDetail: Location?
    @StateObject private var locationManager = LocationManager()
    
    init(viewModel: LocationRowViewModel, title: String, userId: String) {
        self.viewModel = viewModel
        self.title = title
        self.userId = userId
        
        viewModel.configureAndFetchFavorites(userId: userId)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack (spacing: 5) {
                Image("heart.pin")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20)
                Text(title)
                    .font(.system(size: 25, weight: .bold))
                    .foregroundColor(.primary)
            }.padding(.leading)
            if viewModel.favoritesInfo.isEmpty {
                PlaceholderView()
            } else {
                switch viewModel.fetchState {
                case .loading, .idle, .error:
                    PlaceholderTransparentView()
                case .loaded:
                    ScrollViewReader { scrollView in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 5) {
                                ForEach(viewModel.favoritesInfo, id: \.businessId) { location in
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

struct FavoritesRowView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = LocationRowViewModel()
        return FavoritesRowView(
            viewModel: viewModel,
            title: "Favorites",
            userId: "wiVOrMOJ8COqs7d6OgCBNVTV9lt2"
        )
    }
}
