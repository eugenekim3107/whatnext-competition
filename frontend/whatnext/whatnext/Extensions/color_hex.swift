//
//  color_hex.swift
//  whatnext
//
//  Created by Eugene Kim on 1/21/24.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue:  Double(b) / 255, opacity: Double(a) / 255)
    }
}

enum CommodityColor {
    case gold
    case silver
    case platinum
    case bronze
    var colors: [Color] {
        switch self {
        case .gold: return [ Color(hex: "0xDBB400"),
                             Color(hex: "0xEFAF00"),
                             Color(hex: "0xF5D100"),
                             Color(hex: "0xF5D100"),
                             Color(hex: "0xD1AE15"),
                             Color(hex: "0xDBB400"),
        ]
            
        case .silver: return [ Color(hex: "0x70706F"),
                               Color(hex: "0x7D7D7A"),
                               Color(hex: "0xB3B6B5"),
                               Color(hex: "0x8E8D8D"),
                               Color(hex: "0xB3B6B5"),
                               Color(hex: "0xA1A2A3"),
        ]
            
        case .platinum: return [ Color(hex: "0x000000"),
                               Color(hex: "0x444444"),
                               Color(hex: "0x000000"),
                               Color(hex: "0x444444"),
                               Color(hex: "0x111111"),
                               Color(hex: "0x000000"),
        ]
            
        case .bronze: return [ Color(hex: "0x804A00"),
                               Color(hex: "0x9C7A3C"),
                               Color(hex: "0xB08D57"),
                               Color(hex: "0x895E1A"),
                               Color(hex: "0x804A00"),
                               Color(hex: "0xB08D57"),
        ]}
    }
    
    var linearGradient: LinearGradient
    {
        return LinearGradient(
            gradient: Gradient(colors: self.colors),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
