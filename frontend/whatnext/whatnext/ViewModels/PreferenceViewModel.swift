import Foundation
import SwiftUI

class PreferenceViewModel: ObservableObject {
    @Published var ACTags: [(String, Bool)] = []
    @Published var FDTags: [(String, Bool)] = []

    private let profileService = ProfileService() // Updated to use ProfileService

    func fetchTags(userId: String,activityAllTags: [String], foodAndDrinkAllTags: [String]) {
        let tagMappings: [String: String] = [
            "Chinese Food": "chinese",
            "Shopping": "shopping"
        ]
        profileService.fetchTags(userId: userId) { [weak self] result in // Using ProfileService's fetchTags
            DispatchQueue.main.async {
                switch result {
                case .success(let tagsResponse):
                    self?.ACTags = activityAllTags.map { tag in
                        let mappedTag = tagMappings[tag] ?? tag
                        return (tag, tagsResponse.activitiesTag.contains(mappedTag))
                    }
                    self?.FDTags = foodAndDrinkAllTags.map { tag in
                        let mappedTag = tagMappings[tag] ?? tag
                        return (tag, tagsResponse.foodAndDrinksTag.contains(mappedTag))
                                        }
                case .failure(let error):
                    print("Error fetching tags: \(error.localizedDescription)")
                }
            }
        }
    }

    func saveSelectionsToDatabase(userId:String) {
        // Example: Combine all selected tags into one array
        let selectedACTags = ACTags.filter { $0.1 }.map { $0.0 }
        let selectedFDTags = FDTags.filter { $0.1 }.map { $0.0 }
        
        // Example: Post these selections to your database
        // This is a placeholder for your database logic
        print(selectedACTags)
        print(selectedFDTags)
        profileService.updateTags(userId: userId, activitiesTag: selectedACTags, foodAndDrinksTag: selectedFDTags) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let updateResponse):
                        // Handle success, maybe update some state or show a success message
                        print("Tags successfully updated: \(updateResponse)")
                    case .failure(let error):
                        // Handle error, maybe show an error message to the user
                        print("Error updating tags: \(error.localizedDescription)")
                    }
                }
            }
    }
}

extension PreferenceViewModel {
    func toggleACTagSelection(for tag: String) {
        if let index = ACTags.firstIndex(where: { $0.0 == tag }) {
            ACTags[index].1.toggle()
        }
    }
    
    func toggleFDTagSelection(for tag: String) {
        if let index = FDTags.firstIndex(where: { $0.0 == tag }) {
            FDTags[index].1.toggle()
        }
    }
}
