//
//  LessonsView.swift
//  Classes
//
//  Created by Nick Baughan on 07/09/2020.
//

import SwiftUI

struct LessonsView: View {
    
    @State var filter: LessonsFilter
    var body: some View {
        #if os(macOS)
        LessonsNavMac(filter: $filter)
        #else
        LessonsListContent(filter: $filter)
        #endif
    }
}

struct AllLessonsView_Previews: PreviewProvider {
    static var previews: some View {
        LessonsView(filter: LessonsFilter(filterType: .all, lessonType: nil))
    }
}
