//
//  LocationService.swift
//  whatnext
//
//  Created by Eugene Kim on 1/24/24.
//

import Foundation

class LocationService {
    func fetchNearbyLocations(latitude: Double? = 32.8723812680163,
                              longitude: Double? = -117.21242234341588,
                              limit: Int? = 20,
                              radius: Double? = 10000.0,
                              categories: [String]? = ["any"],
                              curOpen: Int? = 0,
                              tag: [String]? = nil,
                              sortBy: String? = "review_count",
                              completion: @escaping (Result<[Location], Error>) -> Void) {
        
        var components = URLComponents(string: "https://api.whatnext.live/nearby_locations")
        var queryItems: [URLQueryItem] = []
        
        // Standard parameters
        let standardParams: [(String, String?)] = [
            ("latitude", latitude.map { String($0) }),
            ("longitude", longitude.map { String($0) }),
            ("limit", limit.map(String.init)),
            ("radius", radius.map { String($0) }),
            ("cur_open", curOpen.map(String.init)),
            ("sort_by", sortBy)
        ]
        
        for (name, value) in standardParams where value != nil {
            queryItems.append(URLQueryItem(name: name, value: value))
        }
        
        // Categories and tag require special handling to join array elements
        if let categoriesValue = categories?.joined(separator: ","), !categoriesValue.isEmpty {
            queryItems.append(URLQueryItem(name: "categories", value: categoriesValue))
        }

        if let tagValue = tag?.joined(separator: ","), !tagValue.isEmpty {
            queryItems.append(URLQueryItem(name: "tag", value: tagValue))
        }
        
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            completion(.failure(NSError(domain: "InvalidURL", code: -1, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
//        request.addValue("whatnext", forHTTPHeaderField: "whatnext_token")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: -2, userInfo: nil)))
                return
            }
            
            do {
                let locations = try JSONDecoder().decode([Location].self, from: data)
                completion(.success(locations))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
