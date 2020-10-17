//
//  LessonsView.swift
//  Classes
//
//  Created by Nick Baughan on 07/09/2020.
//

import SwiftUI

struct LessonsView: View {
    // MARK: - Environment
    @Environment(\.managedObjectContext) var viewContext
    
    @State var filter: LessonsFilter
    @State private var selection = Set<Lesson>()
    
    // MARK: - View States
    
    @EnvironmentObject var viewStates: LessonsStateObject
    
    @State private var lessonTags = [Tag]()
    
    let nc = NotificationCenter.default
    
    var body: some View {
        Group {
            #if os(macOS)
            LessonsNavMac(selectedLesson: $selection, filter: $filter)
            #else
            LessonsListContent(selection: $selection, filter: $filter)
            #endif
        }
    }
}

struct AllLessonsView_Previews: PreviewProvider {
    static var previews: some View {
        LessonsView(filter: LessonsFilter(filterType: .all, lessonType: nil)).environmentObject(LessonsStateObject())
    }
}
