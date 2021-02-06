//
//  LessonTypePicker.swift
//  Classes
//
//  Created by Nick Baughan on 06/02/2021.
//

import SwiftUI

struct LessonTypePicker: View {
    @Binding var type: Lesson.LessonType
    var body: some View {
        Picker(selection: $type, label: Label("Lesson Type", systemImage: "book"), content: /*@START_MENU_TOKEN@*/{
            ForEach(Lesson.LessonType.allCases) { type in
                Text(type.rawValue).tag(type)
            }
        }/*@END_MENU_TOKEN@*/)
    }
}
