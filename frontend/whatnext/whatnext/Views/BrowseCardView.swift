//
//  BrowseCardView.swift
//  whatnext
//
//  Created by Eugene Kim on 3/12/24.
//

import SwiftUI

struct BrowseCardView: View {
    var location: Location
    @State private var offset = CGSize.zero
    @State private var color: Color = Color(UIColor.systemGroupedBackground)

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.6)
                    .border(.white, width: 6.0)
                    .cornerRadius(4)
                    .foregroundColor(color.opacity(0.9))
                    .shadow(radius:4)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color.clear)
        }
        .offset(x: offset.width, y: offset.height * 0.4)
        .rotationEffect(.degrees(Double(offset.width / 40)))
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                    withAnimation {
                        changeColor(width: offset.width)
                    }
                } .onEnded { _ in
                    withAnimation {
                        swipeCard(width: offset.width)
                        changeColor(width: offset.width)
                    }
                }
        )
    }
    func swipeCard(width: CGFloat) {
        switch width {
        case -500...(-200):
            offset = CGSize(width: -500, height: 0)
        case 200...500:
            offset = CGSize(width: 500, height: 0)
        default:
            offset = .zero
        }
    }
    
    func changeColor(width: CGFloat) {
        switch width {
        case -500...(-100):
            color = .red.opacity(0.8)
        case 100...(500):
            color = .green.opacity(0.8)
        default:
            color = Color(UIColor.systemGroupedBackground)
        }
    }
}

#Preview {
    BrowseCardView(location: Location(
        businessId: "1",
        name: "Shorehouse Kitchen",
        imageUrl: "https://s3-media2.fl.yelpcdn.com/bphoto/cln5YeBlyDYnhYU8fASAng/o.jpg",
        phone: "+18584593300",
        displayPhone: "(858) 459-3300",
        address: "2236 Avenida De La Playa",
        city: "La Jolla",
        state: "CA",
        postalCode: "92037",
        latitude: 32.8539270057529,
        longitude: -117.254643428836,
        stars: 4.5,
        reviewCount: 2098,
        curOpen: 0,
        categories: ["New American", "Salad", "Sandwiches"],
        tag: ["coffee", "breakfast_brunch", "newamerican"],
        hours: Hours(
            Monday: ["0730","1430"],
            Tuesday: ["0730","1430"],
            Wednesday: ["0730","1430"],
            Thursday: ["0730","1430"],
            Friday: ["0730","1530"],
            Saturday: ["0730","1530"],
            Sunday: ["0730","1530"]
        ),
        location: GeoJSON(type: "Point", coordinates: [-117.254643428836, 32.8539270057529]),
        price: "$$"
    ))
}
