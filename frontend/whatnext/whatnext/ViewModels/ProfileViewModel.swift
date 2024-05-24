//
//  ProfileViewModel.swift
//  whatnext
//
//  Created by Eugene Kim on 1/21/24.
//

import Foundation

class ProfileViewModel: ObservableObject {
    enum FetchState {
        case idle
        case loading
        case loaded
        case error(String)
    }
    @Published var userInfo: UserInfo?
    @Published var errorMessage: String?
    @Published var fetchState = FetchState.idle
    private let profileService = ProfileService()

    func fetchUserInfo(userId: String) {
        guard case .idle = fetchState else { return }
        fetchState = .loading
        
        profileService.fetchUserInfo(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let userInfo):
                    self?.userInfo = userInfo
                    self?.fetchState = .loaded
                case .failure(let error):
                    print("Error fetching user info: \(error.localizedDescription)")
                    self?.userInfo = nil
                    self?.fetchState = .error(error.localizedDescription)
                }
            }
        }
    }
    
    func configureAndFetchUserInfo(userId: String) {
        fetchUserInfo(userId: userId)
    }
    
    func refreshDataUserProfile(userId: String) {
        self.fetchState = .idle
        configureAndFetchUserInfo(userId: userId)
    }
}
