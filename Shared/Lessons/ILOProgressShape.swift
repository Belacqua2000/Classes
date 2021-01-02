//
//  ILOProgressShape.swift
//  Classes
//
//  Created by Nick Baughan on 03/12/2020.
//

import SwiftUI

struct ILOProgressGauge: View {
    
    #if os(iOS)
    @ScaledMetric(relativeTo: .body) var iconSize: CGFloat = 17
    #else
    @ScaledMetric(relativeTo: .body) var iconSize: CGFloat = 13
    #endif
    
    @ObservedObject var lesson: Lesson
    
    var completedILOs: Double {
        return Double((lesson.ilo?.allObjects as? [ILO])?.filter({$0.written}).count ?? 0)
    }
    
    var totalILOs: Double {
        return Double(lesson.iloCount)
    }
    
    var body: some View {
        
        ILOProgressShape(amountComplete: completedILOs/totalILOs)
            .stroke(Color.accentColor, lineWidth: 2)
            .frame(width: iconSize, height: iconSize)
            .overlay(
                Text(totalILOs != 0 ? (nf.string(from: NSNumber(value: completedILOs/totalILOs)) ?? "") : "")
                    .fixedSize(horizontal: true, vertical: false)
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .offset(x: 0, y: iconSize)
            )
    }
    
    private let nf: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .percent
        return nf
    }()
}

struct ILOProgressShape: Shape {
    
    var amountComplete: Double
    
    var animatableData: Double {
        get { amountComplete }
        set { self.amountComplete = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        let startAngle = Angle.degrees(-90)
        let endAngle = Angle.degrees(360 * amountComplete - 90)
        
        var path = Path()
        
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        
        return path
    }
    
}

/*struct ILOProgressShape_Previews: PreviewProvider {
    static var previews: some View {
        ILOProgressGauge(amountComplete: 6/6)
    }
}*/
