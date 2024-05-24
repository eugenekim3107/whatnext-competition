//
//  PreViewModel.swift
//  whatnext
//
//  Created by Nicholas Lyu on 3/1/24.
//

import SwiftUI

class PreViewModel: ObservableObject {
    @Published var firstArray: [String] = []
    @Published var secondArray: [String] = []

    func uploadData() {
        // Implement your database upload logic here
        print("Uploading data: \(firstArray), \(secondArray)")
    }
}
