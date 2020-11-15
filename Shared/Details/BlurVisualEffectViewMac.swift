//
//  BlurVisualEffectViewMac.swift
//  Classes (macOS)
//
//  Created by Nick Baughan on 06/11/2020.
//

import SwiftUI

struct BlurVisualEffectViewMac: NSViewRepresentable {
    var material: NSVisualEffectView.Material = .headerView
    var blendMode: NSVisualEffectView.BlendingMode = .withinWindow
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendMode
        return view
    }
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendMode
    }
}

struct BlurVisualEffectViewMac_Previews: PreviewProvider {
    static var previews: some View {
        BlurVisualEffectViewMac()
    }
}
