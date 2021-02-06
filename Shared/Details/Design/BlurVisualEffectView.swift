//
//  BlurVisualEffectView.swift
//  Classes
//
//  Created by Nick Baughan on 06/11/2020.
//

import SwiftUI

struct BlurVisualEffectView: UIViewRepresentable {
    var style: UIBlurEffect.Style = .systemMaterial
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

struct BlurVisualEffectView_Previews: PreviewProvider {
    static var previews: some View {
        BlurVisualEffectView()
    }
}
