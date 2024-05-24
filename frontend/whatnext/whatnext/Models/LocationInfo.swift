//
//  LocationInfo.swift
//  whatnext
//
//  Created by Eugene Kim on 1/24/24.
//

import Foundation

// Define the GeoJSON structure for the location
struct GeoJSON: Codable, Hashable {
    let type: String
    let coordinates: [Double]
}

// Define the structure for the opening hours
struct Hours: Codable, Hashable {
    let Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday: [String]?
    
    // Add a computed property to get a dictionary with formatted strings
    var formattedHours: [String: String] {
        let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        var formattedHoursDict: [String: String] = [:]

        for day in daysOfWeek {
            if let dayHours = self.hours(for: day) {
                let openTime = dayHours.open.insert(separator: ":", every: 2)
                let closeTime = dayHours.close.insert(separator: ":", every: 2)
                formattedHoursDict[day] = "\(openTime) - \(closeTime)"
            }
        }

        return formattedHoursDict
    }

    func hours(for day: String) -> (open: String, close: String)? {
        switch day {
            case "Monday": return formatHours(Monday)
            case "Tuesday": return formatHours(Tuesday)
            case "Wednesday": return formatHours(Wednesday)
            case "Thursday": return formatHours(Thursday)
            case "Friday": return formatHours(Friday)
            case "Saturday": return formatHours(Saturday)
            case "Sunday": return formatHours(Sunday)
            default: return nil
        }
    }

    private func formatHours(_ times: [String]?) -> (open: String, close: String)? {
        guard let openTime = times?.first, let closeTime = times?.last else { return nil }
        return (openTime, closeTime)
    }
}

// Define the main Location structure
struct Location: Codable, Identifiable, Hashable {
    var id: String { businessId }
    let businessId: String
    let name: String
    let imageUrl: String?
    let phone, displayPhone, address, city: String?
    let state, postalCode: String?
    let latitude, longitude: Double?
    let stars: Double?
    let reviewCount: Int?
    let curOpen: Int?
    let categories: [String]?
    let tag: [String]?
    let hours: Hours?
    let location: GeoJSON
    let price: String?
    
    enum CodingKeys: String, CodingKey {
        case businessId = "business_id"
        case name, imageUrl = "image_url", phone, displayPhone = "display_phone", address, city, state, postalCode = "postal_code", latitude, longitude, stars, reviewCount = "review_count", curOpen = "cur_open", categories, tag, hours, location, price
    }
}

// Define a struct to hold the array of locations for the API response
struct LocationsResponse: Codable {
    let locations: [Location]
}
