//
//  DetailBlock.swift
//  Classes
//
//  Created by Nick Baughan on 08/02/2021.
//

import SwiftUI

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
