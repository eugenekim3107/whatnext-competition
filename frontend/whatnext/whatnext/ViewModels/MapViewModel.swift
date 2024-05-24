//
//  MapViewModel.swift
//  whatnext
//
//  Created by Eugene Kim on 1/21/24.
//  Updated by Mike on 1/28/24
//

import Foundation
import MapKit

class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    var region: MKCoordinateRegion
    @Published var locations: [Location] = []
    private let locationManager = CLLocationManager()
    private let locationService = LocationService()
    private var initialLocationSet = false // Add a flag to check if initial location is set

    
    override init() {
        self.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 32.880977, longitude: -117.237853),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first, !initialLocationSet else { return }
        DispatchQueue.main.async {
            self.region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            self.initialLocationSet = true // Mark the initial location as set
        }
//        loadDummyLocations()
        // Fetch locations using LocationRowViewModel
        loadLocationsForMapView(from: location.coordinate)
    }
    
    func searchInNewArea(center: CLLocationCoordinate2D) {
        // Perform the search using the center of the map view
        print("Searching near the center location: \(center.latitude), \(center.longitude)")
        //loadDummyLocations()
        loadLocationsForMapView(from: center)
    }
    
    private func loadLocationsForMapView(from coordinate: CLLocationCoordinate2D) {
        // Initially clear the locations if you want to refresh the data
        self.locations.removeAll()

        // Group for coordinating the two fetch calls
        let fetchGroup = DispatchGroup()

        // Fetch food locations
        fetchGroup.enter()
        locationService.fetchNearbyLocations(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            limit: 10,
            radius: 30000.0,
            categories: ["all"],
            curOpen: 0,
            sortBy: "rating"
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let locations):
                    self?.locations.append(contentsOf: locations)
                case .failure(let error):
                    print("Error fetching food locations: \(error)")
                }
                fetchGroup.leave()
            }
        }

        // Fetch fitness locations
        fetchGroup.enter()
        locationService.fetchNearbyLocations(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            limit: 10,
            radius: 30000.0,
            categories: ["fitness"],
            curOpen: 0,
            sortBy: "rating"
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let locations):
                    self?.locations.append(contentsOf: locations)
                case .failure(let error):
                    print("Error fetching fitness locations: \(error)")
                }
                fetchGroup.leave()
            }
        }

        // Once both calls are complete, update the UI if needed
        fetchGroup.notify(queue: .main) {
            // Update UI or perform any additional operations after both fetches are complete
        }
    }


    
    func loadDummyLocations() {
        // Correctly assign dummy data to locations
        self.locations = [
            Location(businessId: "1fRCPsVzhhQr3C691KQnIg", name: "Eureka!", imageUrl: "https://s3-media1.fl.yelpcdn.com/bphoto/PW7eQbNYQ8Iu6Aeofg8BOQ/o.jpg", phone: "+18582103444", displayPhone: "(858) 210-3444", address: "4353 La Jolla Village Dr ,San Diego, CA 92122", city: "San Diego", state: "CA", postalCode: "92122", latitude: 32.870379, longitude: -117.211938, stars: 3.9, reviewCount: 1822, curOpen: 1, categories: ["restaurant", "all"], tag: ["tradamerican"], hours: Hours(Monday: ["1100","0000"], Tuesday: ["1100","0000"], Wednesday: ["1100","0000"], Thursday: ["1100","0000"], Friday: ["1100","0100"], Saturday: ["1100","0100"], Sunday: ["1100","0000"]), location: GeoJSON(type: "Point", coordinates: [-117.211938, 32.870379]), price: "$$")
        ]
    }
}
