//
//  MapView.swift
//  whatnext
//
//  Created by Eugene Kim on 1/21/24.
//  updated by Mike on 1/28/24

import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var viewModel = MapViewModel()
    @State private var trackingMode: MapUserTrackingMode = .follow
    @State private var selectedLocation: Location?
    @State private var userHasInteracted = false
    @State private var showRecenterButton = false
    @GestureState private var magnification: CGFloat = 1.0
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        ZStack {
            Map(coordinateRegion: $viewModel.region,
                interactionModes: .all,
                showsUserLocation: true,
                userTrackingMode: $trackingMode,
                annotationItems: viewModel.locations) { location in
                    MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: location.latitude ?? 0, longitude: location.longitude ?? 0)) {
                        Button(action: {
                            DispatchQueue.main.async {
                                self.selectedLocation = location
                            }
                        }) {
                            pinImage(for: location.categories ?? [""]) // Now accepts [String]
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                        }
                    }
                }
                .gesture(
                    DragGesture().onChanged({ _ in 
                        userHasInteracted = true
                        showRecenterButton = true
                    })
                )
                .ignoresSafeArea(edges: .all)
            
            // Only show the button if the user has interacted with the map
            if userHasInteracted && showRecenterButton {
                VStack {
                    Button("Search This Area") {
                        viewModel.searchInNewArea(center: viewModel.region.center)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue.opacity(0.8))
                    .cornerRadius(30)
                    .padding(.top, 50)
                    .transition(.opacity)
                    .animation(.easeInOut, value: userHasInteracted)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .edgesIgnoringSafeArea(.top)
                
                
                VStack {
                    Spacer() // Pushes the button to the bottom
                    HStack {
                        Spacer() // Pushes the button to the right
                        Button(action: {
                            // Action to recenter the map to the user's current location
                            if let userLocation = locationManager.currentUserLocation {
                                withAnimation {
                                    viewModel.region = MKCoordinateRegion(center: userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                                    showRecenterButton = false // Hide recenter button after action
                                }
                            }
                        }) {
                            Image(systemName: "location.fill")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue.opacity(0.8))
                                .cornerRadius(30)
                                .shadow(radius: 3)
                        }
                        .padding(.bottom, 100)
                        .padding(.trailing, 20)
                        .transition(.scale.combined(with: .opacity))
                        .animation(.easeInOut, value: userHasInteracted)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }
        }
        .sheet(item: $selectedLocation) { location in
            LocationDetailView(location: location, userLocation: locationManager.currentUserLocation)
        }
    }

    private func pinImage(for categories: [String]) -> Image {
        if categories.contains("food") {
            return Image("food.pin")
        } else if categories.contains("fitness") {
            return Image("fitness.pin")
        } else if categories.contains("shopping") {
            return Image("shopping.pin")
        } else if categories.contains("mountain") {
            return Image("mountain.pin")
        } else {
            return Image("heart.pin")
        }
    }
}

struct AnnotationView: View {
    let imageUrl: String

    var body: some View {
        if URL(string: imageUrl) != nil {
            AsyncImageView(urlString: imageUrl)
                .frame(width: 60, height: 60) // Customize the size as needed
                .clipShape(Rectangle())
        } else {
            // Provide a fallback view in case the URL is invalid
            Image(systemName: "logo-1")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .clipShape(Rectangle())
        }
    }
}

extension Location {
    var CLLocationCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0)
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
