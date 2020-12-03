//
//  DetailViewStates.swift
//  Classes
//
//  Created by Nick Baughan on 15/11/2020.
//

import Foundation

class DetailViewStates: ObservableObject {
    @Published var editLessonShown: Bool = false
    @Published var lessonToChange: Lesson?
    
    @Published var deleteAlertShown: Bool = false
    @Published var addResourcePresented: Bool = false
    @Published var addILOPresented: Bool = false
    @Published var editILOViewState: EditILOView.AddOutcomeViewState = .single
    @Published var tagShown: Bool = false
}
