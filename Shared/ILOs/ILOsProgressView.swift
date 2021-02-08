//
//  ILOsProgressView.swift
//  Classes
//
//  Created by Nick Baughan on 08/02/2021.
//

import SwiftUI

struct ILOsProgressView: View {
    var completedILOs: Double
    
    var progressView: some View {
        ProgressView(value: completedILOs)
            .progressViewStyle(LinearProgressViewStyle())
    }
    
    var text: some View {
        Text("\(numberFormatter.string(from: NSNumber(value: completedILOs))!) of learning outcomes achieved")
            .fixedSize(horizontal: false, vertical: true)
    }
    
    var body: some View {
        #if !os(watchOS)
        HStack {
            text
            progressView
        }
        #else
        VStack {
            text
            progressView
        }
        #endif
    }
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        return formatter
    }()
}

struct ILOsProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ILOsProgressView(completedILOs: 0.8)
    }
}
