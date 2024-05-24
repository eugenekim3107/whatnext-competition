//
//  File.swift
//  whatnext
//
//  Created by Mike Dong on 3/14/24.
//

import SwiftUI

struct UserDetailView: View {
    let userInfo: UserInfo
    @StateObject var favoritesModel = LocationRowViewModel()
    @StateObject var visitedModel = LocationRowViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                if let imageUrl = userInfo.imageUrl {
                    AsyncImageProfileView(urlString: imageUrl)
                        .frame(width: 110, height: 110)
                        .clipShape(Circle())
                        .padding(.top, 25)
                } else {
                    // Placeholder view when imageUrl is nil
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 110, height: 110)
                        .padding(.top, 25)
                }
                
                Text(userInfo.displayName)
                    .font(.title)
                    .fontWeight(.medium)
                    .padding(.top, 10)
                
                HStack(spacing: 25) {
                    StatView(label: "Friends", value: "\(userInfo.friendsCount)", imageName: "friends.pin")
                    StatView(label: "Visited", value: "\(userInfo.visitedCount)", imageName: "visited.pin")
                    StatView(label: "Favorites", value: "\(userInfo.favoritesCount)", imageName: "heart.pin")
                }
                .padding()
                
                FavoritesRowView(
                    viewModel: favoritesModel,
                    title: "Favorites",
                    userId: userInfo.userId
                )
                
                VisitedRowView(
                    viewModel: visitedModel,
                    title: "Visited",
                    userId: userInfo.userId
                )
            }
        }
        .onAppear {
            favoritesModel.refreshDataFavorites(userId: userInfo.userId)
            visitedModel.refreshDataVisited(userId: userInfo.userId)
        }
    }
}

struct StatView: View {
    var label: String
    var value: String
    var imageName: String
    
    var body: some View {
        VStack {
            Text(value)
                .font(.headline)
            HStack (spacing: 3){
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 10)
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
        }
    }
}

struct UserDetailView_Previews: PreviewProvider {
    static var previews: some View {
        UserDetailView(userInfo: UserInfo(userId: "1", displayName: "John Doe", imageUrl: nil, friends: ["2", "3"], visited: ["Place1", "Place2"], favorites: ["Place2", "Place3"]))
    }
}
