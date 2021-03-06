//
//  DetailToolbar.swift
//  Classes
//
//  Created by Nick Baughan on 06/02/2021.
//

import SwiftUI

struct DetailToolbar: ToolbarContent {
    #if os(iOS)
    var horizontalSizeClass: UserInterfaceSizeClass
    #endif
    @ObservedObject var lesson: Lesson
    @ObservedObject var viewStates: LessonsListHelper
    @ObservedObject var detailStates: DetailViewStates
    @Binding var tagShown: Bool
    
    var body: some ToolbarContent {
        #if os(iOS)
        ToolbarItemGroup(placement: .primaryAction) {
            if horizontalSizeClass == .regular {
                DeleteLessonButton(viewStates: detailStates, lesson: lesson)
                EditLessonButton(detailStates: detailStates, lesson: lesson)
            } else {
                Menu(content: {
                    DeleteLessonButton(viewStates: detailStates, lesson: lesson)
                    EditLessonButton(detailStates: detailStates, lesson: lesson)
                    Button(action: showTags, label: {
                        Label("Edit Tags", systemImage: "tag")
                    })
                    .help("Edit the tags for this lesson")
                }, label: {
                    Label("More Actions", systemImage: "ellipsis.circle")
                })
                .imageScale(.large)
            }
        }
        
        
        ToolbarItem(placement: .navigationBarLeading) {
            if horizontalSizeClass == .regular {
                Button(action: showTags, label: {
                    Label("Edit Tags", systemImage: "tag")
                })
                .help("Edit the tags for this lesson")
            }
        }
        #else
        ToolbarItem(id: "Toggle Watched Button", placement: .automatic) {
            ToggleWatchedButton(lesson: lesson)
        }
        
        ToolbarItem(id: "Tag Button", placement: .automatic) {
            Button(action: showTags, label: {
                Label("Edit Tags", systemImage: "tag")
            })
            .help("Edit the tags for this lesson")
        }
        
        ToolbarItem(id: "Spacer") {
            Spacer()
        }
        
        ToolbarItem(id: "AddILOMenu", placement: .automatic) {
            AddILOMenu(detailStates: detailStates)
        }
        
        ToolbarItem(id: "AddResourceButton", placement: .automatic) {
            AddResourceButton(isAddingResource: $detailStates.addResourcePresented)
        }
        
        ToolbarItem(id: "DeleteButton") {
            DeleteLessonButton(viewStates: detailStates)
        }
        ToolbarItem(id: "EditButton") {
            EditLessonButton(detailStates: detailStates, lesson: lesson)
                .labelStyle(TitleOnlyLabelStyle())
        }
        #endif
    }
    
    private func showTags() {
        tagShown = true
    }
}
