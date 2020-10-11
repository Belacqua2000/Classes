//
//  LessonsNaviOS.swift
//  Classes (iOS)
//
//  Created by Nick Baughan on 11/10/2020.
//

import SwiftUI

struct LessonsNaviOS: View {
    @State var isListShowing: Bool
    
    @State private var deleteAlertShown = false
    @State private var addLessonIsPresented = false
    @State private var addResourcePresented = false
    @State private var addILOPresented = false
    @State private var editILOViewState: EditILOView.AddOutcomeViewState = .single
    @State private var lessonToEdit: Lesson? = nil
    @State private var shareSheetShown = false
    
    @State private var lessonTags = [Tag]()
    
    
    var body: some View {
        Text("Hello World!")
    }
}

struct LessonsNaviOS_Previews: PreviewProvider {
    static var previews: some View {
        LessonsNaviOS(isListShowing: true)
    }
}
