//
//  RatingView.swift
//  Classes
//
//  Created by Nick Baughan on 13/02/2021.
//

import SwiftUI

struct RatingView: View {
    @State var rating = 1.0
    
    var stars: some View {
        var i = Text("")
        for _ in 0..<Int(rating) {
            i = i + Text("\(Image(systemName: "star.fill").renderingMode(.original))")
        }
        return i
    }
    var body: some View {
        VStack {
            HStack {
                Label("Rating", systemImage: "star")
                    .font(.headline)
                Spacer()
            }
            stars
                .font(.title)
//                .lineLimit(1)
                .minimumScaleFactor(0.5)
            Slider(
                value: $rating,
                in: 1...5,
                step: 1,
                onEditingChanged: {_ in },
                minimumValueLabel: Text("1"),
                maximumValueLabel: Text("5"),
                label: {Label("Rating", systemImage: "star")}).labelsHidden()
        }
    }
}

struct RatingView_Previews: PreviewProvider {
    static var previews: some View {
        RatingView()
    }
}
