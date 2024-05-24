//
//  InteractiveLocationView.swift
//  whatnext
//
//  Created by Eugene Kim on 2/13/24.
//

import SwiftUI
import CoreLocation

struct InteractiveLocationView: View {
    var locations: [Location]
    
    @State private var locationStates = [String: LocationState]()
    @State private var zIndexToOffsetMap: [Double: CGSize] = [:]
    @State private var draggingOffset: CGSize = .zero
    @State private var currentlyDragging: String? = nil
    @State private var topLocation: String? = nil
    @State private var bottomLocation: String? = nil
    @State private var showingLocationDetail: Location?
    @StateObject private var locationManager = LocationManager()
    
    private enum LocationState {
        case left(offset: CGSize, zIndex: Double)
        case right(offset: CGSize, zIndex: Double)
    }
    
    init(locations: [Location]) {
        self.locations = locations
        
        var initialStates = [String: LocationState]()
        
        let xOffsetStep: CGFloat = -10.0
        let maxZIndexForDynamicOffset = 5
        let baseOffsetDecayFactor: CGFloat = 0.9
        var zIndexToOffsetMapTemp: [Double: CGSize] = [:]
        var topLocationTemp: String? = nil
        var bottomLocationTemp: String? = nil

        var lastOffset = CGSize(width: 0, height: 0)
        
        for (index, location) in locations.enumerated() {
            let zIndex = Double(locations.count - index)
            let dynamicOffset = pow(baseOffsetDecayFactor, CGFloat(index)) * xOffsetStep
            
            let offset: CGSize
            
            if index < maxZIndexForDynamicOffset {
                offset = CGSize(width: CGFloat(index) * dynamicOffset, height: 0)
                lastOffset = offset
            } else {
                offset = lastOffset
            }
            
            if index == 0 {
                zIndexToOffsetMapTemp[zIndex] = offset
                initialStates[location.businessId] = .right(offset: offset, zIndex: zIndex)
                bottomLocationTemp = location.businessId
            } else if zIndex == 1 {
                zIndexToOffsetMapTemp[zIndex] = offset
                initialStates[location.businessId] = .left(offset: offset, zIndex: zIndex)
                topLocationTemp = location.businessId
            } else {
                zIndexToOffsetMapTemp[zIndex] = offset
                initialStates[location.businessId] = .left(offset: offset, zIndex: zIndex)
            }
        }
        
        _topLocation = State(initialValue: topLocationTemp)
        _bottomLocation = State(initialValue: bottomLocationTemp)
        _zIndexToOffsetMap = State(initialValue: zIndexToOffsetMapTemp)
        _locationStates = State(initialValue: initialStates)
    }
    
    var body: some View {
        ZStack {
            ForEach(locations, id: \.businessId) { location in
                if let state = locationStates[location.businessId] {
                    LocationSearchSimpleView(location: location)
                        .offset(x: currentlyDragging == location.businessId ? draggingOffset.width : getOffset(from: state).width,
                                    y: getOffset(from: state).height)
                        .zIndex(getZIndex(from: state))
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    self.draggingOffset = gesture.translation
                                    self.currentlyDragging = location.businessId
                                }
                                .onEnded { gesture in
                                    let swipeDirection = gesture.translation.width
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        self.currentlyDragging = nil
                                        self.draggingOffset = .zero
                                    }
                                    
                                    let direction: SwipeDirection = swipeDirection > 0 ? .right : .left
                                    
                                    let currentLocation = findCurrentLocation()
                                    
                                    if (direction == .right && currentLocation != topLocation) || (direction == .left && currentLocation != bottomLocation) {
                                        withAnimation(.easeOut(duration: 0.3)) {
                                            swipeLocation(location.businessId, direction: direction)
                                        }
                                    }
                                }
                        )
                        .onTapGesture { // Tap gesture to show the detail view
                            showingLocationDetail = location
                        }
                }
            }
        }
        .sheet(item: $showingLocationDetail) { // Sheet presentation for the location detail view
            LocationDetailView(location: $0, userLocation: locationManager.currentUserLocation)
        }
    }
    
    enum SwipeDirection {
        case left
        case right
    }

    private func getOffset(from state: LocationState) -> CGSize {
        switch state {
        case .left(let offset, _), .right(let offset, _):
            return offset
        }
    }

    private func getZIndex(from state: LocationState) -> Double {
        switch state {
        case .left(_, let zIndex), .right(_, let zIndex):
            return zIndex
        }
    }
    
    private func findCurrentLocation() -> String? {
        var highestZIndex: Double = Double.leastNormalMagnitude
        var currentBusinessId: String? = nil

        for (businessId, state) in locationStates {
            let zIndex: Double
            switch state {
            case .left(_, let z), .right(_, let z):
                zIndex = z
            }

            if zIndex > highestZIndex {
                highestZIndex = zIndex
                currentBusinessId = businessId
            }
        }

        return currentBusinessId
    }
    
    private func swipeLocation(_ businessId: String, direction: SwipeDirection) {
        guard let _ = locationStates[businessId] else { return }

        var newStates = [String: LocationState]()
        let totalLocations = Double(locations.count)

        switch direction {
        case .right:
            newStates = adjustStatesForRightSwipe(businessId: businessId, total: totalLocations)
        case .left:
            newStates = adjustStatesForLeftSwipe(businessId: businessId, total: totalLocations)
        }

        locationStates = newStates
    }

    private func adjustStatesForRightSwipe(businessId: String, total: Double) -> [String: LocationState] {
        var newStates = [String: LocationState]()
        
        for (_, location) in locations.enumerated() {
            guard let currentState = locationStates[location.businessId] else { continue }
            
            let currentZIndex: Double
            let currentOffset: CGSize
            switch currentState {
            case .left(_, let zIndex):
                if zIndex == total {
                    currentZIndex = zIndex - 1
                    let retrievedOffset = zIndexToOffsetMap[currentZIndex] ?? CGSize(width: CGFloat(currentZIndex) * -10.0, height: 0)
                    currentOffset = CGSize(width: -retrievedOffset.width, height: retrievedOffset.height)
                    newStates[location.businessId] = .right(offset: currentOffset, zIndex: currentZIndex)
                } else {
                    currentZIndex = zIndex + 1
                    let retrievedOffset = zIndexToOffsetMap[currentZIndex] ?? CGSize(width: CGFloat(currentZIndex) * -10.0, height: 0)
                    currentOffset = CGSize(width: retrievedOffset.width, height: retrievedOffset.height)
                    newStates[location.businessId] = .left(offset: currentOffset, zIndex: currentZIndex)
                }
                
            case .right(_, let zIndex):
                currentZIndex = zIndex - 1
                let retrievedOffset = zIndexToOffsetMap[currentZIndex] ?? CGSize(width: CGFloat(currentZIndex) * -10.0, height: 0)
                currentOffset = CGSize(width: -retrievedOffset.width, height: retrievedOffset.height)
                newStates[location.businessId] = .right(offset: currentOffset, zIndex: currentZIndex)
            }
        }
        return newStates
    }
    
    private func adjustStatesForLeftSwipe(businessId: String, total: Double) -> [String: LocationState] {
        var newStates = [String: LocationState]()
        
        for (_, location) in locations.enumerated() {
            guard let currentState = locationStates[location.businessId] else { continue }
            
            let currentZIndex: Double
            let currentOffset: CGSize
            
            switch currentState {
            case .right(_, let zIndex):
                if zIndex == total {
                    currentZIndex = zIndex - 1
                    let retrievedOffset = zIndexToOffsetMap[currentZIndex] ?? CGSize(width: CGFloat(currentZIndex) * -10.0, height: 0)
                    currentOffset = CGSize(width: retrievedOffset.width, height: retrievedOffset.height)
                    newStates[location.businessId] = .left(offset: currentOffset, zIndex: currentZIndex)
                } else {
                    currentZIndex = zIndex + 1
                    let retrievedOffset = zIndexToOffsetMap[currentZIndex] ?? CGSize(width: CGFloat(currentZIndex) * -10.0, height: 0)
                    currentOffset = CGSize(width: -retrievedOffset.width, height: retrievedOffset.height)
                    newStates[location.businessId] = .right(offset: currentOffset, zIndex: currentZIndex)
                }
                
            case .left(_, let zIndex):
                currentZIndex = zIndex - 1
                let retrievedOffset = zIndexToOffsetMap[currentZIndex] ?? CGSize(width: CGFloat(currentZIndex) * -10.0, height: 0)
                currentOffset = CGSize(width: retrievedOffset.width, height: retrievedOffset.height)
                newStates[location.businessId] = .left(offset: currentOffset, zIndex: currentZIndex)
            }
        }
        return newStates
    }

}

struct LocationSearchSimpleView: View {
    var location: Location
    @State private var showingLocationDetail: Location?

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                if URL(string: location.imageUrl ?? "") != nil {
                    AsyncImageView(urlString: location.imageUrl ?? "")
                        .frame(width: 200, height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                } else {
                    Color.gray.opacity(0.3)
                }
                
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .resizable()
                        .frame(width: 15, height: 15)
                        .foregroundColor(.yellow)
                    Group {
                        if let stars = location.stars {
                            Text(String(format: "%.1f", stars))
                        } else {
                            Text("N/A")
                        }
                    }
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                }
                .padding(3)
                .background(Color.gray)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .padding([.top, .leading], 5)
            }
            .frame(width: 200, height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            Text(location.name)
                .font(.system(size: 20))
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .truncationMode(.tail)
                .fixedSize(horizontal: false, vertical: true)
                .frame(height: 50)
                .frame(width: 180)
                .padding([.top, .bottom])
        }
        .background(Color.white)
        .shadow(color:Color.black.opacity(0.6), radius:3, x:0, y:0)
    }
}

struct InteractiveLocationView_Previews: PreviewProvider {
    static var previews: some View {
        // Create some sample locations to preview
        let exampleLocations = [
            Location(
                businessId: "001",
                name: "Coffee Central Park Avenue",
                imageUrl: "https://s3-media1.fl.yelpcdn.com/bphoto/vxSx2j9gnJ-dWu9OFYyhRQ/o.jpg",
                phone: nil,
                displayPhone: nil,
                address: nil,
                city: nil,
                state: nil,
                postalCode: nil,
                latitude: nil,
                longitude: nil,
                stars: nil,
                reviewCount: nil,
                curOpen: nil,
                categories: nil,
                tag: nil,
                hours: nil,
                location: GeoJSON(type: "Point", coordinates: [-74.005974, 40.712776]),
                price: nil
            ),
            Location(
                businessId: "002",
                name: "Coffee Place",
                imageUrl: nil,
                phone: nil,
                displayPhone: nil,
                address: nil,
                city: nil,
                state: nil,
                postalCode: nil,
                latitude: nil,
                longitude: nil,
                stars: nil,
                reviewCount: nil,
                curOpen: nil,
                categories: nil,
                tag: nil,
                hours: nil,
                location: GeoJSON(type: "Point", coordinates: [-73.005974, 41.712776]),
                price: nil
            ),
            Location(
                businessId: "003",
                name: "Please",
                imageUrl: nil,
                phone: nil,
                displayPhone: nil,
                address: nil,
                city: nil,
                state: nil,
                postalCode: nil,
                latitude: nil,
                longitude: nil,
                stars: nil,
                reviewCount: nil,
                curOpen: nil,
                categories: nil,
                tag: nil,
                hours: nil,
                location: GeoJSON(type: "Point", coordinates: [-74.205974, 40.711776]),
                price: nil
            ),
            Location(
                businessId: "004",
                name: "Huh",
                imageUrl: nil,
                phone: nil,
                displayPhone: nil,
                address: nil,
                city: nil,
                state: nil,
                postalCode: nil,
                latitude: nil,
                longitude: nil,
                stars: nil,
                reviewCount: nil,
                curOpen: nil,
                categories: nil,
                tag: nil,
                hours: nil,
                location: GeoJSON(type: "Point", coordinates: [-74.205974, 40.711776]),
                price: nil
            ),
            Location(
                businessId: "005",
                name: "What",
                imageUrl: nil,
                phone: nil,
                displayPhone: nil,
                address: nil,
                city: nil,
                state: nil,
                postalCode: nil,
                latitude: nil,
                longitude: nil,
                stars: nil,
                reviewCount: nil,
                curOpen: nil,
                categories: nil,
                tag: nil,
                hours: nil,
                location: GeoJSON(type: "Point", coordinates: [-74.205974, 40.711776]),
                price: nil
            ),
            Location(
                businessId: "006",
                name: "PWhda",
                imageUrl: nil,
                phone: nil,
                displayPhone: nil,
                address: nil,
                city: nil,
                state: nil,
                postalCode: nil,
                latitude: nil,
                longitude: nil,
                stars: nil,
                reviewCount: nil,
                curOpen: nil,
                categories: nil,
                tag: nil,
                hours: nil,
                location: GeoJSON(type: "Point", coordinates: [-74.205974, 40.711776]),
                price: nil
            ),
        ]



        InteractiveLocationView(locations: exampleLocations)
    }
}
