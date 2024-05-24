//
//  ProfileInfo.swift
//  whatnext
//
//  Created by Eugene Kim on 2/20/24.
//

import Foundation

struct UserInfo: Identifiable, Decodable {
    var id: String { userId }
    let userId: String
    let displayName: String
    let imageUrl: String?
    var friends: [String]
    var visited: [String]
    var favorites: [String]
    var friendsCount: Int { friends.count }
    var visitedCount: Int { visited.count }
    var favoritesCount: Int { favorites.count }

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case displayName = "display_name"
        case imageUrl = "image_url"
        case friends, visited, favorites
    }
}

struct FriendsInfo: Identifiable, Decodable {
    var id: String { userId }
    let userId: String
    let friendsInfo: [UserInfo]

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case friendsInfo = "friends_info"
    }
}

struct VisitedInfo: Identifiable, Decodable {
    var id: String {userId}
    let userId: String
    let locations: [Location]
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case locations = "visited_locations"
    }
}

struct FavoritesInfo: Codable, Identifiable {
    var id: String { userId }
    let userId: String
    let favoritesLocations: [Location]

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case favoritesLocations = "favorites_locations"
    }
}

struct TagsResponse: Decodable {
    let activitiesTag: [String]
    let foodAndDrinksTag: [String]
    let userId: String

    enum CodingKeys: String, CodingKey {
        case activitiesTag = "activities_tag"
        case foodAndDrinksTag = "food_and_drinks_tag"
        case userId = "user_id"
    }
}

struct UpdateTagsResponse:Decodable{
    let operation:Bool
    let userId:String
    
    
    enum CodingKeys: String, CodingKey {
        case operation = "operation"
        case userId = "user_id"
    }
}
