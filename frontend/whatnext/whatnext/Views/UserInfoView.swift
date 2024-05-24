//
//  UserInfoView.swift
//  whatnext
//
//  Created by Eugene Kim on 3/9/24.
//

import SwiftUI

struct UserInfoView: View {
    @ObservedObject var viewModel: ProfileViewModel
    let userId: String
    
    init(viewModel: ProfileViewModel, userId: String) {
        self.viewModel = viewModel
        self.userId = userId
        
        viewModel.configureAndFetchUserInfo(userId: userId)
    }
    
    var body: some View {
        HStack (spacing: 20) {
            VStack (spacing: 3) {
                if URL(string: viewModel.userInfo?.imageUrl ?? "") != nil {
                    AsyncImageProfileView(urlString:viewModel.userInfo?.imageUrl ?? "")
                        .frame(width: 110, height: 110)
                        .clipShape(Circle())
                } else {
                    ProfilePlaceholderView()
                }
                
                Text(viewModel.userInfo?.displayName ?? "Loading...")
                    .multilineTextAlignment(.center)
                    .truncationMode(.tail)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(height: 40)
                    .frame(width: 110)
            }
            ProfileStatistics(
            friendsCount: viewModel.userInfo?.friends.count ?? 0,
            favoritesCount: viewModel.userInfo?.favorites.count ?? 0,
            visitedCount: viewModel.userInfo?.visited.count ?? 0
            )
        }
    }
}

struct ProfilePlaceholderView: View {
    var body: some View {
        Circle()
            .fill(Color.gray.opacity(0.3))
            .frame(width: 110, height: 110)
    }
}

struct ProfileStatistics: View {
    let friendsCount: Int
    let favoritesCount: Int
    let visitedCount: Int

    var body: some View {
        HStack (spacing: 20) {
            statisticView(count: friendsCount, imageName: "friends.pin", label: "Friends")
            statisticView(count: favoritesCount, imageName: "heart.pin", label: "Favorites")
            statisticView(count: visitedCount, imageName: "visited.pin", label: "Visited")
        }
    }

    private func statisticView(count: Int, imageName: String, label: String) -> some View {
        VStack {
            Text("\(count)")
            HStack (spacing: 3) {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 10)
                Text(label).font(.system(size: 13))
            }
        }
    }
}

struct UserInfoView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ProfileViewModel()
        return UserInfoView(viewModel: viewModel,
                       userId: "wiVOrMOJ8COqs7d6OgCBNVTV9lt2")
    }
}
