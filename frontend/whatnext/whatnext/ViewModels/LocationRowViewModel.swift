//
//  LocationRowViewModel.swift
//  whatnext
//
//  Created by Eugene Kim on 1/24/24.
//

import Foundation

class LocationRowViewModel: ObservableObject {
    enum FetchState {
        case idle
        case loading
        case loaded
        case error(String)
    }
    @Published var locations: [Location] = []
    @Published var favoritesInfo: [Location] = []
    @Published var visitedInfo: [Location] = []
    @Published var fetchState = FetchState.idle
    private let locationService = LocationService()
    private let profileService = ProfileService()

    func fetchNearbyLocations(latitude: Double, longitude: Double, limit: Int, radius: Double, categories: [String], curOpen: Int, tag: [String]? = nil, sortBy: String) {
        guard case .idle = fetchState else { return }
        fetchState = .loading
        
        locationService.fetchNearbyLocations(latitude: latitude, longitude: longitude, limit: limit, radius: radius, categories: categories, curOpen: curOpen, tag: tag, sortBy: sortBy) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let locations):
                    self?.locations = locations
                    self?.fetchState = .loaded
                case .failure(let error):
                    print("Error fetching locations: \(error.localizedDescription)")
                    self?.locations = []
                    self?.fetchState = .error(error.localizedDescription)
                }
            }
        }
    }
    
    func configureAndFetchLocations(latitude: Double, longitude: Double, limit: Int, radius: Double, categories: [String], curOpen: Int, tag: [String]? = nil, sortBy: String) {
        fetchNearbyLocations(latitude: latitude, longitude: longitude, limit: limit, radius: radius, categories: categories, curOpen: curOpen, tag: tag, sortBy: sortBy)
    }
    
    func refreshDataLocations(latitude: Double, longitude: Double, limit: Int, radius: Double, categories: [String], curOpen: Int, tag: [String]? = nil, sortBy: String) {
        self.fetchState = .idle
        configureAndFetchLocations(latitude: latitude, longitude: longitude, limit: limit, radius: radius, categories: categories, curOpen: curOpen, tag: tag, sortBy: sortBy)
    }
    
    func fetchFavoritesInfo(userId: String) {
        guard case .idle = fetchState else { return }
        fetchState = .loading
        
        profileService.fetchFavoritesInfo(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let favoritesInfo):
                    self?.favoritesInfo = favoritesInfo.favoritesLocations
                    self?.fetchState = .loaded
                case .failure(let error):
                    print("Error fetching locations: \(error.localizedDescription)")
                    self?.favoritesInfo = []
                    self?.fetchState = .error(error.localizedDescription)
                }
            }
        }
    }
    
    func configureAndFetchFavorites(userId: String) {
        fetchFavoritesInfo(userId: userId)
    }
    
    func refreshDataFavorites(userId: String) {
        self.fetchState = .idle
        configureAndFetchFavorites(userId: userId)
    }
    
    func fetchVisitedInfo(userId: String) {
        guard case .idle = fetchState else { return }
        fetchState = .loading
        
        profileService.fetchVisitedInfo(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let visitedInfo):
                    self?.visitedInfo = visitedInfo.locations
                    self?.fetchState = .loaded
                case .failure(let error):
                    print("Error fetching locations: \(error.localizedDescription)")
                    self?.visitedInfo = []
                    self?.fetchState = .error(error.localizedDescription)
                }
            }
        }
    }
    
    func configureAndFetchVisited(userId: String) {
        fetchVisitedInfo(userId: userId)
    }
    
    func refreshDataVisited(userId: String) {
        self.fetchState = .idle
        configureAndFetchVisited(userId: userId)
    }
}
