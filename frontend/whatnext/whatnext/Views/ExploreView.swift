//
//  ExploreView.swift
//  whatnext
//
//  Created by Eugene Kim on 1/21/24.
//

import SwiftUI

struct ExploreView: View {
    @StateObject var viewModel1 = LocationRowViewModel()
    @StateObject var viewModel2 = LocationRowViewModel()
    @StateObject var viewModel3 = LocationRowViewModel()
    @StateObject var viewModel4 = LocationRowViewModel()
    
    var body: some View {

        NavigationView {
            ScrollView {
                VStack (spacing: 0) {
                    LocationRowView(
                        viewModel: viewModel1,
                        title: "Food and Drinks",
                        latitude: 32.88088,
                        longitude: -117.23790,
                        categories: ["food"],
                        radius: 5000,
                        curOpen: 0,
                        sortBy: "random",
                        limit: 15
                    )
                    LocationRowView(
                        viewModel: viewModel2,
                        title: "Coffee Spots",
                        latitude: 32.88088,
                        longitude: -117.23790,
                        categories: ["food"],
                        radius: 5000,
                        curOpen: 0,
                        tag: ["coffee"],
                        sortBy: "random",
                        limit: 15
                    )
                    LocationRowView(
                        viewModel: viewModel3,
                        title: "Shopping Spree!",
                        latitude: 32.88088,
                        longitude: -117.23790,
                        categories: ["shopping"],
                        radius: 5000,
                        curOpen: 0,
                        tag: ["deptstores"],
                        sortBy: "random",
                        limit: 15
                    )
                    LocationRowView(
                        viewModel: viewModel4,
                        title: "Let's Workout!",
                        latitude: 32.88088,
                        longitude: -117.23790,
                        categories: ["fitness"],
                        radius: 5000,
                        curOpen: 0,
                        sortBy: "random",
                        limit: 15
                    )
                }
                .navigationBarTitle("Explore", displayMode: .large)
                .padding(.top)
                .padding(.bottom, 50)
            }
            .refreshable {
                viewModel1.refreshDataLocations(latitude: 32.88088, longitude: -117.23790, limit: 15, radius: 5000, categories: ["food"], curOpen: 0, sortBy: "random")
                viewModel2.refreshDataLocations(latitude: 32.88088, longitude: -117.23790, limit: 15, radius: 5000, categories: ["food"], curOpen: 0, tag: ["coffee"], sortBy: "random")
                viewModel3.refreshDataLocations(latitude: 32.88088, longitude: -117.23790, limit: 15, radius: 5000, categories: ["shopping"], curOpen: 0, tag: ["deptstores"], sortBy: "random")
                viewModel4.refreshDataLocations(latitude: 32.88088, longitude: -117.23790, limit: 15, radius: 5000, categories: ["fitness"], curOpen: 0, sortBy: "random")
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
    }
}
