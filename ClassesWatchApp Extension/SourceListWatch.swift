//
//  SourceListWatch.swift
//  ClassesWatchApp Extension
//
//  Created by Nick Baughan on 08/02/2021.
//

import SwiftUI

struct SourceListWatch: View {
    
    @State var selection: SourceListItem?
    
    var body: some View {
        List {
            AllLessonsListItem(selection: $selection)
            SmartGroupsList(selection: $selection)
            LessonTypeList()
        }
    }
}

struct SourceListWatch_Previews: PreviewProvider {
    static var previews: some View {
        SourceListWatch()
    }
}
