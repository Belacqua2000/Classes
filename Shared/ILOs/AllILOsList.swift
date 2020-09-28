//
//  AllILOsList.swift
//  Classes
//
//  Created by Nick Baughan on 26/09/2020.
//

import SwiftUI

struct AllILOsList: View {
    var lessons: [Lesson]
    
    var ilos: [ILO]
    var body: some View {
        List {
            ForEach(lessons) { lesson in
                if lesson.ilo?.count ?? 0 > 0 {
                    Section(header: Label(lesson.title ?? "Untitled", systemImage: Lesson.lessonIcon(type: lesson.type))) {
                        ForEach(((lesson.ilo?.allObjects as? [ILO])?.sorted(by: {$0.index < $1.index}))!) { ilo in
                            Text("\(ilo.index+1). \(ilo.title ?? "Untitled")")
                        }
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
    }
    
    /*func sortedILOs(lesson: Lesson) -> [ILO] {
        if let ilos = lesson.ilo as? [ILO] {
            return ilos.sorted(by: {$0})
        }
    }*/
}

struct AllILOsList_Previews: PreviewProvider {
    static var previews: some View {
        AllILOsList(lessons: [], ilos: [])
    }
}
