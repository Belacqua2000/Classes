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
    
    var completedILOs: [ILO] {
        return (lesson.ilo?.allObjects as? [ILO])?.filter({$0.written}) ?? []
    }
    
    var totalILOs: Double {
        return Double(lesson.iloCount)
    }
    
    var body: some View {
        
        ZStack {
            ILOProgressShape(lesson: lesson, amountComplete: Double(completedILOs.count)/totalILOs)
                .stroke(Color.accentColor, lineWidth: 2)
                .frame(width: iconSize, height: iconSize)
            Text(nf.string(from: NSNumber(value: Double(completedILOs.count)/totalILOs)) ?? "")
                .minimumScaleFactor(0.01)
                .font(.footnote)
                .foregroundColor(.gray)
                .offset(x: 0, y: iconSize)
            Text("\((lesson.ilo?.allObjects as? [ILO])?.filter({$0.written}).count ?? 5)")
        }
    }
    
    private let nf: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .percent
        return nf
    }()
}

struct ILOProgressShape: Shape {
    
    @ObservedObject var lesson: Lesson
    
    var amountComplete: Double
    
    func path(in rect: CGRect) -> Path {
        let startAngle = Angle.degrees(-90)
        let endAngle = Angle.degrees(360 * lesson.completedILOs / Double(lesson.iloCount) - 90)
        
        var path = Path()
        
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        
        return path
    }
    
}

/*struct ILOProgressShape_Previews: PreviewProvider {
    static var previews: some View {
        ILOProgressGauge(amountComplete: 6/6)
    }
}*/
