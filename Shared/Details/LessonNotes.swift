//
//  LessonNotes.swift
//  Classes
//
//  Created by Nick Baughan on 06/02/2021.
//

import SwiftUI

struct LessonNotes: View {
    var text: String
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Label("Notes", systemImage: "text.justifyleft")
                    .font(.headline)
                Text(text)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }.modifier(DetailBlock())
    }
}
