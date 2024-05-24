//
//  TypingIndicatorView.swift
//  whatnext
//
//  Created by Eugene Kim on 2/13/24.
//

import SwiftUI

struct TypingIndicatorView: View {
    @State private var animate = false

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<3) { index in
                Circle()
                    .frame(width: 8, height: 8)
                    .foregroundColor(.gray)
                    .scaleEffect(animate ? 1 : 0.5)
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
}


struct TypingIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        TypingIndicatorView()
    }
}
