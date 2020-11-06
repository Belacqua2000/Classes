//
//  DetailBackgroundGradient.swift
//  Classes
//
//  Created by Nick Baughan on 06/11/2020.
//

import SwiftUI

struct DetailBackgroundGradient: View {
    var body: some View {
        VStack(alignment: .leading) {
            Label("Lesson Details", systemImage: "book")
            Text("Teacher: Professor JP Leach")
            Text("Location: Online")
        }.modifier(DetailBlock())
    }
}

struct DetailBlock: ViewModifier {
    #if os(macOS)
    private var backgroundView = BlurVisualEffectViewMac()
    #else
    private var backgroundView = BlurVisualEffectView()
    #endif
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(backgroundView)
            .cornerRadius(8)
            .shadow(radius: 10, x: 10, y: 10)
    }
}

struct DetailBackgroundGradient_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DetailBackgroundGradient()
                .preferredColorScheme(.light)
                .padding()
                .background(Color.blue)
            
            DetailBackgroundGradient()
                .preferredColorScheme(.dark)
                .padding()
                .background(Color.blue)
        }
    }
}
