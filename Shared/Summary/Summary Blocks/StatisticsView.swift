//
//  StatisticsView.swift
//  Classes
//
//  Created by Nick Baughan on 06/11/2020.
//

import SwiftUI

struct StatisticsView: View {
    var lessonsCount: Int
    var ilosCount: Int
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Label("Statistics", systemImage: "chart.pie")
                    .font(.headline)
                Text("Number of lessons: \(lessonsCount)")
                Text("Number of learning outcomes: \(ilosCount)")
            }
            Spacer()
        }.modifier(DetailBlock())
    }
}
