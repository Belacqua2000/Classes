//
//  DetailBackgroundGradient.swift
//  Classes
//
//  Created by Nick Baughan on 06/11/2020.
//

import SwiftUI

struct DetailBackgroundGradient: View {
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [.init("SecondaryColorLight"), .init("SecondaryColor")]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea([.bottom, .horizontal])
    }
}

#if !os(watchOS)
struct DetailBackgroundGradient_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            
            VStack(alignment: .leading) {
                Label("Lesson Details", systemImage: "book")
                Text("Teacher: Professor JP Leach")
                Text("Location: Online")
            }.modifier(DetailBlock())
                .preferredColorScheme(.light)
                .padding()
                .background(Color.blue)
            
            
            VStack(alignment: .leading) {
                Label("Lesson Details", systemImage: "book")
                Text("Teacher: Professor JP Leach")
                Text("Location: Online")
            }.modifier(DetailBlock())
                .preferredColorScheme(.dark)
                .padding()
                .background(Color.blue)
        }
    }
}
#endif
