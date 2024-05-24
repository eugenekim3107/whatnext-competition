//
//  TagView.swift
//  whatnext
//
//  Created by Nicholas Lyu on 2/25/24.
//

import SwiftUI

struct TagView: View {
    var text: String
    var isSelected: Bool
    var icon: String
    
    var body: some View {
        HStack {
            Text(icon)
                .font(.system(size: 15)) // Adjust emoji size as needed
                .padding(.leading, 8) // Add padding to ensure the emoji is a fixed distance from the left edge of the tag box
            Text(text)
                .font(Font.custom("Inter", size: 12).weight(isSelected ? .bold : .semibold))
            Spacer() // Ensures the text and icon align to the left
        }
        .padding(.horizontal, 8) // Additional padding for the overall HStack
        .frame(width: 160, height: 45)
        .foregroundColor(isSelected ? .white : .black)
        .background(isSelected ? Color(red: 0.28, green: 0.64, blue: 0.91) : Color.white)
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color(red: 0.91, green: 0.90, blue: 0.92), lineWidth: isSelected ? 0 : 2)
        )
        .shadow(color: isSelected ? Color(red: 0.28, green: 0.64, blue: 0.91).opacity(0.2) : Color.clear, radius: 2, x: 0, y: 2)
    }
}


struct TagView_Previews: PreviewProvider {
    static var previews: some View {
        TagView(text:"Wasian",isSelected: true,icon:"🧑‍🎤")
    }
}

