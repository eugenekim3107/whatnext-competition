//
//  AsyncImageView.swift
//  whatnext
//
//  Created by Eugene Kim on 3/9/24.
//

import SwiftUI

struct AsyncImageView: View {
    @StateObject private var loader = ImageLoader()
//    @State private var size: CGFloat
    let urlString: String
    
    var body: some View {
        Group {
            if loader.isLoadingFailed {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.3))
//                    .frame(width: size, height: size)
            } else if let image = loader.image {
                image
                    .resizable()
                    .scaledToFill()
//                    .frame(width: size, height: size)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            } else {
                ProgressView()
//                    .frame(width: size, height: size)
            }
        }
        .onAppear {
            loader.load(fromURL: urlString)
        }
    }
}

struct AsyncImageProfileView: View {
    @StateObject private var loader = ImageLoader()
    let urlString: String
    
    var body: some View {
        Group {
            if loader.isLoadingFailed {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 110, height: 110)
            } else if let image = loader.image {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 110, height: 110)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            } else {
                ProgressView()
                    .frame(width: 110, height: 110)
            }
        }
        .onAppear {
            loader.load(fromURL: urlString)
        }
    }
}

