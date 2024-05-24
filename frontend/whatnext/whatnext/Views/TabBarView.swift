//
//  TabBarView.swift
//  whatnext
//
//  Created by Eugene Kim on 1/23/24.
//

import SwiftUI

enum Tab: String, CaseIterable {
    case map
    case search
    case explore
    case profile
    case more
}

struct TabBarView: View {
    @Binding var selectedTab: Tab
    @Environment(\.colorScheme) var colorScheme
    
    private var fillImage: String {
        selectedTab.rawValue + ".fill"
    }
    
    private var foregroundGradient: LinearGradient {
        switch colorScheme {
        case .dark:
            return ShineColor.shinyWhite.linearGradient
        default:
            return ShineColor.platinum.linearGradient
        }
    }
    
    private var backgroundGradient: LinearGradient {
        switch colorScheme {
        case .dark:
            return ShineColor.gold.linearGradient
        default:
            return ShineColor.gold.linearGradient
        }
    }

    var body: some View {
        VStack {
            HStack {
                ForEach(Tab.allCases, id: \.rawValue) { tab in
                    Spacer()
                    Image(selectedTab == tab ? fillImage : tab.rawValue)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(foregroundGradient, backgroundGradient)
                        .scaleEffect(selectedTab == tab ? 1.25 : 1.0)
                        .font(.system(size: 24))
                        .onTapGesture {
                            withAnimation(.easeIn(duration: 0.1)) {
                                selectedTab = tab
                            }
                        }
                    Spacer()
                }
            }
            .frame(height: 60)
            .background(.thinMaterial)
            .cornerRadius(10)
            .padding()
        }
    }
}



enum ShineColor {
    case gold
    case silver
    case platinum
    case emerald
    case shinyBlue
    case bronze
    case shinyWhite
    var colors: [Color] {
        switch self {
        case .gold: return [ 
            Color(hex: 0xC19A6B),
            Color(hex: 0xD4AF37),
            Color(hex: 0xF7E9A0),
            Color(hex: 0xE6C200),
            Color(hex: 0xFFD700),
            Color(hex: 0xC19A6B),
        ]
        case .silver: return [ 
            Color(hex: 0x70706F),
            Color(hex: 0x7D7D7A),
            Color(hex: 0xB3B6B5),
            Color(hex: 0x8E8D8D),
            Color(hex: 0xB3B6B5),
            Color(hex: 0xA1A2A3),
        ]
        case .platinum: return [ 
            Color(hex: 0x000000),
            Color(hex: 0x444444),
            Color(hex: 0x000000),
            Color(hex: 0x444444),
            Color(hex: 0x111111),
            Color(hex: 0x000000),
        ]
        case .emerald: return [
            Color(hex: 0x046307),
            Color(hex: 0x04855A),
            Color(hex: 0x04B487),
            Color(hex: 0x03A675),
            Color(hex: 0x02875F),
            Color(hex: 0x046307),
        ]
        case .shinyBlue: return [
            Color(hex: 0x87CEFA),
            Color(hex: 0xB0E2FF),
            Color(hex: 0xE0FFFF),
            Color(hex: 0xB0E2FF),
            Color(hex: 0xADD8E6),
            Color(hex: 0x87CEFA),
        ]
        case .bronze: return [ 
            Color(hex: 0x804A00),
            Color(hex: 0x9C7A3C),
            Color(hex: 0xB08D57),
            Color(hex: 0x895E1A),
            Color(hex: 0x804A00),
            Color(hex: 0xB08D57),
        ]
        case .shinyWhite: return [
            Color(hex: 0xFFFFFF),
            Color(hex: 0xF0F0F0),
            Color(hex: 0xE0E0E0),
            Color(hex: 0xF0F0F0),
            Color(hex: 0xFFFFFF),
            Color(hex: 0xF0F0F0),
            Color(hex: 0xFFFFFF)
            ]
        }
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
extension View {
    func shine(_ color: ShineColor) -> some View {
        ZStack {
            self.opacity(0)
            color.linearGradient.mask(self)
        }.fixedSize()
    }
}
fileprivate extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init( .sRGB,
                   red: Double((hex >> 16) & 0xff) / 255,
                   green: Double((hex >> 08) & 0xff) / 255,
                   blue: Double((hex >> 00) & 0xff) / 255,
                   opacity: alpha )
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView(selectedTab: .constant(.explore))
    }
}
