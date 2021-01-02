//
//  LessonsStateObject.swift
//  Classes
//
//  Created by Nick Baughan on 11/10/2020.
//

import Foundation

class LessonsStateObject: ObservableObject {
    @Published var deleteAlertShown: Bool = false
    @Published var addLessonIsPresented: Bool = false
    @Published var addResourcePresented: Bool = false
    @Published var addILOPresented: Bool = false
    @Published var editILOViewState: EditILOView.AddOutcomeViewState = .single
    @Published var lessonToChange: Lesson? = nil
    @Published var shareSheetShown = false
    @Published var exporterShown = false
    @Published var tagPopoverPresented = false
}
