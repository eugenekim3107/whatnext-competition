//
//  ProfileRowViewModel.swift
//  whatnext
//
//  Created by Eugene Kim on 2/19/24.
//

import Foundation

class ProfileRowViewModel: ObservableObject {
    enum FetchState {
        case idle
        case loading
        case loaded
        case error(String)
    }
    @Published var friendsInfo: [UserInfo] = []
    @Published var fetchState = FetchState.idle
    private let profileService = ProfileService()

    func fetchFriendsInfo(userId: String) {
        guard case .idle = fetchState else { return }
        fetchState = .loading
        
        profileService.fetchFriendsInfo(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let friendsInfo):
                    self?.friendsInfo = friendsInfo.friendsInfo
                    self?.fetchState = .loaded
                case .failure(let error):
                    print("Error fetching locations: \(error.localizedDescription)")
                    self?.friendsInfo = []
                    self?.fetchState = .error(error.localizedDescription)
                }
            }
        }
    }
    
    func configureAndFetchInfo(userId: String) {
        fetchFriendsInfo(userId: userId)
    }
    
    func refreshDataProfiles(userId: String) {
        self.fetchState = .idle
        configureAndFetchInfo(userId: userId)
    }
}
