//
//  ImageLoader.swift
//  whatnext
//
//  Created by Eugene Kim on 3/9/24.
//

import Foundation
import SwiftUI
import Combine

class ImageLoader: ObservableObject {
    @Published var image: Image? = nil
    @Published var isLoadingFailed = false
    private var cancellable: AnyCancellable?
    
    func load(fromURL urlString: String) {
        guard let url = URL(string: urlString), !urlString.isEmpty else {
            self.isLoadingFailed = true
            return
        }
        
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse,
                      (200...299).contains(response.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                return output.data
            }
            .map { UIImage(data: $0) }
            .map { Image(uiImage: $0 ?? UIImage()) }
            .catch { _ in Just(nil) }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loadedImage in
                if let image = loadedImage {
                    self?.image = image
                    self?.isLoadingFailed = false
                } else {
                    self?.isLoadingFailed = true
                }
            }
    }
    
    deinit {
        cancellable?.cancel()
    }
}

