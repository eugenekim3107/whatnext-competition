//
//  VisitedRowView.swift
//  whatnext
//
//  Created by Eugene Kim on 2/21/24.
//

import SwiftUI
import CoreLocation

struct VisitedRowView: View {
    @ObservedObject var viewModel: LocationRowViewModel
    let title: String
    let userId: String
    @State private var showingLocationDetail: Location?
    @StateObject private var locationManager = LocationManager()
    
    init(viewModel: LocationRowViewModel, title: String, userId: String) {
        self.viewModel = viewModel
        self.title = title
        self.userId = userId
        
        viewModel.configureAndFetchVisited(userId: userId)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack (spacing: 5) {
                Image("visited.pin")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20)
                Text(title)
                    .font(.system(size: 25, weight: .bold))
                    .foregroundColor(.primary)
            }.padding(.leading)
            if viewModel.visitedInfo.isEmpty {
                PlaceholderView()
            } else {
                switch viewModel.fetchState {
                case .loading, .idle, .error:
                    PlaceholderTransparentView()
                case .loaded:
                    ScrollViewReader { scrollView in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 5) {
                                ForEach(viewModel.visitedInfo, id: \.businessId) { location in
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

struct VisitedRowView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = LocationRowViewModel()
        return VisitedRowView(
            viewModel: viewModel,
            title: "Visited",
            userId: "wiVOrMOJ8COqs7d6OgCBNVTV9lt2"
        )
    }
}
