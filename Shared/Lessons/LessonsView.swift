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
    @EnvironmentObject var appViewState: AppViewState
    
    @State var listType: LessonsListType
    @State var exporterShown = false
    
    // MARK: - View States
    
    @EnvironmentObject var listHelper: LessonsListHelper
    
    var body: some View {
        LessonsListContent(listHelper: listHelper, listType: $listType)
                .fileExporter(
                    isPresented: $listHelper.exporterShown,
                    document: LessonJSON(lessons: Array(listHelper.selection)),
                    contentType: .classesFormat,
                    onCompletion: {_ in })
    }
}
