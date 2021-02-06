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
    
    @State var listType: LessonsListType
    
    @State private var selection = Set<Lesson>()
    
    // MARK: - View States
    
    @EnvironmentObject var lessonsListHelper: LessonsListHelper
    
    @State private var lessonTags = [Tag]()
    
    let nc = NotificationCenter.default
    
    var body: some View {
            LessonsListContent(listType: $listType)
    }
}
