//
//  LessonsListToolbar.swift
//  Classes
//
//  Created by Nick Baughan on 06/02/2021.
//

import SwiftUI

struct LessonsListToolbar: ToolbarContent {
    let nc = NotificationCenter.default
    
    @ObservedObject var listHelper: LessonsListHelper
    @ObservedObject var listFilter: LessonsListFilter
    @Binding var listType: LessonsListType
    
    var addLessonButton: some View {
        Button(action: {nc.post(.init(name: .newLesson))}, label: {
            Label("Add Lesson", systemImage: "plus")
        })
        .onReceive(nc.publisher(for: .newLesson), perform: { _ in
            listHelper.sheetToPresent = .addLesson
        })
        .help("Add a New Lesson")
    }
    
    var scrollButton: some View {
        Button(action: {
            nc.post(Notification(name: .scrollToNow))
        }, label: {
            Label("Scroll To Now", systemImage: "calendar.badge.clock")
        })
        .help("Scroll to the next lesson in the list after now.")
    }
    
    var iloButton: some View {
        Button(action: {listHelper.ilosViewShown = true}, label: {
            Label("Generate Learning Outcomes", systemImage: "list.number")
        })
        .help("View ILOs")
        .help("View the Learning Outcome Randomiser for the current selection of lessons")
        .onReceive(nc.publisher(for: .showILORandomiser), perform: { _ in
//            sheetToPresent = .ilo
        })
    }
    
    var filterButton: some View {
        Button(action: {listHelper.filterViewActive = true}, label: {
            Label("Filter", systemImage: listFilter.anyFilterActive ? "line.horizontal.3.decrease.circle.fill" : "line.horizontal.3.decrease.circle")
        })
        .help("Filter Lessons in the View")
        .sheet(isPresented: $listHelper.filterViewActive) {
            NavigationView {
                LessonsFilterView(viewShown: $listHelper.filterViewActive, listType: listType, filter: listFilter)
            }
        }
        .onReceive(nc.publisher(for: .showFilterView), perform: { _ in
//            sheetToPresent = .filter
        })
    }
    
    var body: some ToolbarContent {
        
        ToolbarItem(id: "AddLessonButton", placement: .primaryAction) {
            addLessonButton
        }
        
        #if os(iOS)
        // BOTTOM BAR BREAKS IN STACKNAVIGATIONVIEWSTYLE
        /*ToolbarItemGroup(placement: .bottomBar) {
         BottomToolbar(selection: $selection, lessonCount: filteredLessons.count)*/
        
        ToolbarItemGroup(placement: .bottomBar) {
            scrollButton
            Spacer()
            iloButton
            Spacer()
            filterButton
        }
        
        #else
        
        ToolbarItem(id: "ScrollNowButton", placement: .automatic) {
            scrollButton
        }
        
        ToolbarItem(id: "ILO", placement: .automatic) {
            iloButton
        }
        
        ToolbarItem(id: "Filter", placement: .automatic) {
            filterButton
        }
        
        #endif
    }
}
