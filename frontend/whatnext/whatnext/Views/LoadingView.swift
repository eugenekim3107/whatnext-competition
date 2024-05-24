//  LoadingView.swift
//  whatnext
//
//  Created by Eugene Kim on 1/21/24.
//

import SwiftUI

struct LoadingView: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    @State private var selectedTab: Tab = .explore
    
    var body: some View {
        if isActive {
            ContentView()
        } else {
            VStack(spacing: 0) {
                VStack (spacing: 20) {
                    Image("logo-3")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                }
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 1.2)) {
                        self.size = 0.9
                        self.opacity = 1.0
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hex: "5BC0EB"))
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
