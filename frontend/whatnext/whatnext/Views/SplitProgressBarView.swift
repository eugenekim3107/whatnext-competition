//
//  SplitProgressBarView.swift
//  whatnext
//
//  Created by Nicholas Lyu on 2/25/24.
//
import SwiftUI
struct SplitProgressBarView: View {
    var leftProgress: Double
    var rightProgress: Double
    let gap: CGFloat = 4 // Width of the gap between the two bars

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Left bar background
                Rectangle()
                    .frame(width: geometry.size.width / 2 - gap / 2, height: 4)
                    .opacity(0.3)
                    .foregroundColor(Color.gray)

                // Right bar background
                Rectangle()
                    .frame(width: geometry.size.width / 2 - gap / 2, height: 4)
                    .opacity(0.3)
                    .foregroundColor(Color.gray)
                    .offset(x: geometry.size.width / 2 + gap / 2)
                
                // Left progress bar
                Rectangle()
                    .frame(width: (geometry.size.width / 2 - gap / 2) * CGFloat(leftProgress), height: 4)
                    .foregroundColor(Color(UIColor.systemBlue))
                    .animation(.linear, value: leftProgress)
                
                // Right progress bar
                Rectangle()
                    .frame(width: (geometry.size.width / 2 - gap / 2) * CGFloat(rightProgress), height: 4)
                    .offset(x: geometry.size.width / 2 + gap / 2) // Offset includes the gap
                    .foregroundColor(Color(UIColor.systemBlue))
                    .animation(.linear, value: rightProgress)
            }
        }
        .cornerRadius(2.0) // Adjust corner radius as needed
    }
}

struct SplitProgressBarView_Previews: PreviewProvider {
    static var previews: some View {
        SplitProgressBarView(leftProgress:1, rightProgress: 0)
    }
}
